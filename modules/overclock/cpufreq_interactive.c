/*
 * drivers/cpufreq/cpufreq_interactive.c
 *
 * Copyright (C) 2010 Google, Inc.
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Author: Mike Chan (mike@android.com)
 *
 */

#include <linux/cpu.h>
#include <linux/cpumask.h>
#include <linux/cpufreq.h>
#include <linux/mutex.h>
#include <linux/sched.h>
#include <linux/tick.h>
#include <linux/timer.h>
#include <linux/workqueue.h>

#include <asm/cputime.h>

#include "../symsearch/symsearch.h"

SYMSEARCH_DECLARE_FUNCTION_STATIC(unsigned long, _nr_running, void);

static void (*pm_idle_old)(void);
static atomic_t active_count = ATOMIC_INIT(0);

static DEFINE_PER_CPU(struct timer_list, cpu_timer);

static DEFINE_PER_CPU(u64, time_in_idle);
static DEFINE_PER_CPU(u64, idle_exit_time);

static struct cpufreq_policy *policy;
static unsigned int target_freq;

/* Workqueues handle frequency scaling */
static struct workqueue_struct *up_wq;
static struct workqueue_struct *down_wq;
static struct work_struct freq_scale_work;

static u64 freq_change_time;
static u64 freq_change_time_in_idle;

static cpumask_t work_cpumask;

/*
 * The minimum ammount of time to spend at a frequency before we can ramp down,
 * default is 50ms.
 */
#define DEFAULT_MIN_SAMPLE_TIME 50000;
static unsigned long min_sample_time;

static int cpufreq_governor_interactive(struct cpufreq_policy *policy,
		unsigned int event);

#ifndef CONFIG_CPU_FREQ_DEFAULT_GOV_INTERACTIVE
static
#endif
struct cpufreq_governor cpufreq_gov_interactive = {
	.name = "interactive",
	.governor = cpufreq_governor_interactive,
	.max_transition_latency = 10000000,
	.owner = THIS_MODULE,
};

static void cpufreq_interactive_timer(unsigned long data)
{
	u64 delta_idle;
	u64 update_time;
	u64 *cpu_time_in_idle;
	u64 *cpu_idle_exit_time;
	struct timer_list *t;

	u64 now_idle = get_cpu_idle_time_us(data,
						&update_time);


	cpu_time_in_idle = &per_cpu(time_in_idle, data);
	cpu_idle_exit_time = &per_cpu(idle_exit_time, data);

	if (update_time == *cpu_idle_exit_time)
		return;

	delta_idle = cputime64_sub(now_idle, *cpu_time_in_idle);

	/* Scale up if there were no idle cycles since coming out of idle */
	if (delta_idle == 0) {
		if (policy->cur == policy->max)
			return;

		if (_nr_running() < 1)
			return;

		target_freq = policy->max;
		cpumask_set_cpu(data, &work_cpumask);
		queue_work(up_wq, &freq_scale_work);
		return;
	}

	/*
	 * There is a window where if the cpu utlization can go from low to high
	 * between the timer expiring, delta_idle will be > 0 and the cpu will
	 * be 100% busy, preventing idle from running, and this timer from
	 * firing. So setup another timer to fire to check cpu utlization.
	 * Do not setup the timer if there is no scheduled work.
	 */
	t = &per_cpu(cpu_timer, data);
	if (!timer_pending(t) && _nr_running() > 0) {
			*cpu_time_in_idle = get_cpu_idle_time_us(
					data, cpu_idle_exit_time);
			mod_timer(t, jiffies + 2);
	}

	if (policy->cur == policy->min)
		return;

	/*
	 * Do not scale down unless we have been at this frequency for the
	 * minimum sample time.
	 */
	if (cputime64_sub(update_time, freq_change_time) < min_sample_time)
		return;

	target_freq = policy->min;
	cpumask_set_cpu(data, &work_cpumask);
	queue_work(down_wq, &freq_scale_work);
}

static void cpufreq_idle(void)
{
	struct timer_list *t;
	u64 *cpu_time_in_idle;
	u64 *cpu_idle_exit_time;

	pm_idle_old();

	if (!cpumask_test_cpu(smp_processor_id(), policy->cpus))
			return;

	/* Timer to fire in 1-2 ticks, jiffie aligned. */
	t = &per_cpu(cpu_timer, smp_processor_id());
	cpu_idle_exit_time = &per_cpu(idle_exit_time, smp_processor_id());
	cpu_time_in_idle = &per_cpu(time_in_idle, smp_processor_id());

	if (timer_pending(t) == 0) {
		*cpu_time_in_idle = get_cpu_idle_time_us(
				smp_processor_id(), cpu_idle_exit_time);
		mod_timer(t, jiffies + 2);
	}
}

/*
 * Choose the cpu frequency based off the load. For now choose the minimum
 * frequency that will satisfy the load, which is not always the lower power.
 */
static unsigned int cpufreq_interactive_calc_freq(unsigned int cpu)
{
	unsigned int delta_time;
	unsigned int idle_time;
	unsigned int cpu_load;
	u64 current_wall_time;
	u64 current_idle_time;;

	current_idle_time = get_cpu_idle_time_us(cpu, &current_wall_time);

	idle_time = (unsigned int) current_idle_time - freq_change_time_in_idle;
	delta_time = (unsigned int) current_wall_time - freq_change_time;

	cpu_load = 100 * (delta_time - idle_time) / delta_time;

	return policy->cur * cpu_load / 100;
}


/* We use the same work function to sale up and down */
static void cpufreq_interactive_freq_change_time_work(struct work_struct *work)
{
	unsigned int cpu;
	cpumask_t tmp_mask = work_cpumask;
	for_each_cpu(cpu, tmp_mask) {
		if (target_freq == policy->max) {
			if (_nr_running() == 1) {
				cpumask_clear_cpu(cpu, &work_cpumask);
				return;
			}

			__cpufreq_driver_target(policy, target_freq,
					CPUFREQ_RELATION_H);
		} else {
			target_freq = cpufreq_interactive_calc_freq(cpu);
			__cpufreq_driver_target(policy, target_freq,
							CPUFREQ_RELATION_L);
		}
		freq_change_time_in_idle = get_cpu_idle_time_us(cpu,
							&freq_change_time);

		cpumask_clear_cpu(cpu, &work_cpumask);
	}


}

static ssize_t show_min_sample_time(struct kobject *kobj,
				struct attribute *attr, char *buf)
{
	return sprintf(buf, "%lu\n", min_sample_time);
}

static ssize_t store_min_sample_time(struct kobject *kobj,
			struct attribute *attr, const char *buf, size_t count)
{
	return strict_strtoul(buf, 0, &min_sample_time);
}

static struct global_attr min_sample_time_attr = __ATTR(min_sample_time, 0644,
		show_min_sample_time, store_min_sample_time);

static struct attribute *interactive_attributes[] = {
	&min_sample_time_attr.attr,
	NULL,
};

static struct attribute_group interactive_attr_group = {
	.attrs = interactive_attributes,
	.name = "interactive",
};

static int cpufreq_governor_interactive(struct cpufreq_policy *new_policy,
		unsigned int event)
{
	int rc;
	switch (event) {
	case CPUFREQ_GOV_START:
		if (!cpu_online(new_policy->cpu))
			return -EINVAL;

		/*
		 * Do not register the idle hook and create sysfs
		 * entries if we have already done so.
		 */
		if (atomic_inc_return(&active_count) > 1)
			return 0;

		rc = sysfs_create_group(cpufreq_global_kobject,
				&interactive_attr_group);
		if (rc)
			return rc;

		pm_idle_old = pm_idle;
		pm_idle = cpufreq_idle;
		policy = new_policy;
		break;

	case CPUFREQ_GOV_STOP:
		if (atomic_dec_return(&active_count) > 1)
			return 0;

		sysfs_remove_group(cpufreq_global_kobject,
				&interactive_attr_group);

		pm_idle = pm_idle_old;
		del_timer(&per_cpu(cpu_timer, new_policy->cpu));
			break;

	case CPUFREQ_GOV_LIMITS:
		if (new_policy->max < new_policy->cur)
			__cpufreq_driver_target(new_policy,
					new_policy->max, CPUFREQ_RELATION_H);
		else if (new_policy->min > new_policy->cur)
			__cpufreq_driver_target(new_policy,
					new_policy->min, CPUFREQ_RELATION_L);
		break;
	}
	return 0;
}

static int __init cpufreq_interactive_init(void)
{
	unsigned int i;
	struct timer_list *t;
	min_sample_time = DEFAULT_MIN_SAMPLE_TIME;

	SYMSEARCH_BIND_FUNCTION_TO(cpufreq_smartass,nr_running,_nr_running);

	/* Initalize per-cpu timers */
	for_each_possible_cpu(i) {
		t = &per_cpu(cpu_timer, i);
		init_timer_deferrable(t);
		t->function = cpufreq_interactive_timer;
		t->data = i;
	}

	/* Scale up is high priority */
	up_wq = create_rt_workqueue("kinteractive_up");
	down_wq = create_workqueue("knteractive_down");

	INIT_WORK(&freq_scale_work, cpufreq_interactive_freq_change_time_work);

	return cpufreq_register_governor(&cpufreq_gov_interactive);
}

#ifdef CONFIG_CPU_FREQ_DEFAULT_GOV_INTERACTIVE
pure_initcall(cpufreq_interactive_init);
#else
module_init(cpufreq_interactive_init);
#endif

static void __exit cpufreq_interactive_exit(void)
{
	cpufreq_unregister_governor(&cpufreq_gov_interactive);
	destroy_workqueue(up_wq);
	destroy_workqueue(down_wq);
}

module_exit(cpufreq_interactive_exit);

MODULE_AUTHOR("Mike Chan <mike@android.com>");
MODULE_DESCRIPTION("'cpufreq_interactive' - A cpufreq governor for "
	"Latency sensitive workloads");
MODULE_LICENSE("GPL");
