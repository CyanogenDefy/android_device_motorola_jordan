/*
	Motorola Milestone overclock module
	version 1.1-mapphone - 2011-03-30
	by Tiago Sousa <mirage@kaotik.org>, modified by nadlabak, Skrilax_CZ
	License: GNU GPLv2
	<http://www.gnu.org/licenses/old-licenses/gpl-2.0.html>

	Changelog:

	version 1.1-mapphone - 2011-03-30
	- simplified
	- added missing item to frequency table

	version 1.0-mapphone - 2010-11-19
	- automatic symbol detection
	- automatic values detection

	Description:

	The MPU (Microprocessor Unit) clock has 5 discrete pairs of possible
	rate frequencies and respective voltages, of which only 4 are passed
	down to cpufreq as you can see with a tool such as SetCPU.  The
	default frequencies are 125, 250, 500 and 550 MHz (and a hidden
	600).  By using this module, you are changing the highest pair in
	the tables of both cpufreq and MPU frequencies, so it becomes 125,
	250, 500 and, say, 800.  It's quite stable up to 1200; beyond
	that it quickly becomes unusable, specially over 1300, with lockups
	or spontaneous reboots.
*/

#define DRIVER_AUTHOR "Tiago Sousa <mirage@kaotik.org>, nadlabak, Skrilax_CZ"
#define DRIVER_DESCRIPTION "Motorola Milestone CPU overclocking"
#define DRIVER_VERSION "1.1-mapphone-froyo"

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/init.h>

#include <linux/proc_fs.h>
#include <linux/string.h>
#include <linux/vmalloc.h>
#include <asm/uaccess.h>

#include <linux/kallsyms.h>

#include <linux/notifier.h>
#include <linux/cpufreq.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>
#include <linux/device.h>
#include <linux/slab.h>
#include <linux/cpu.h>
#include <linux/completion.h>
#include <linux/mutex.h>

#include <linux/err.h>
#include <linux/clk.h>
#include <linux/io.h>

#include <mach/hardware.h>
#include <asm/system.h>

#include <plat/omap-pm.h>
#include "../symsearch/symsearch.h"

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_VERSION(DRIVER_VERSION);
MODULE_LICENSE("GPL");

extern int cpufreq_stats_freq_update(unsigned int cpu, int index, unsigned int freq);

static uint freq_table_addr = 0;
static uint mpu_opps_addr = 0;
SYMSEARCH_DECLARE_ADDRESS_STATIC(omap2_clk_init_cpufreq_table);

#define MPU_CLK         "arm_fck"

static struct cpufreq_frequency_table *freq_table;
static struct omap_opp *my_mpu_opps;
static struct cpufreq_policy *policy;
static struct clk *mpu_clk;

#define BUF_SIZE PAGE_SIZE
static char *buf;

static void omap2_find_addrs(void)
{
	unsigned char *func = (void *)SYMSEARCH_GET_ADDRESS(omap2_clk_init_cpufreq_table);
	uint *addr;
	int first = 1, i;

	for(i = 0; i < 100; i+=4)
	{
		if((func[i+3] == 0xe5 || func[i+3] == 0x15) /* ldr/ldrne */
			&& func[i+2] == 0x9f) /* [pc, */
		{
			addr = (void *)((uint)func)+i+8+func[i];
			if(first--)
			{
				mpu_opps_addr = *addr;
				printk (KERN_INFO "overclock: found mpu_opps_addr at 0x%x\n", mpu_opps_addr);
			}
			else
			{
				freq_table_addr = *addr;
				printk (KERN_INFO "overclock: found freq_table_addr at 0x%x\n", freq_table_addr);
				break;
			}
		}
	}
}

static int proc_info_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "cpumin=%u cpumax=%u min=%u max=%u usermin=%u usermax=%u\nclk_get_rate=%lu\n",
				policy->cpuinfo.min_freq, policy->cpuinfo.max_freq, policy->min, policy->max, policy->user_policy.min, policy->user_policy.max, clk_get_rate(mpu_clk) / 1000);

	return ret;
}

static int proc_freq_table_addr_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "0x%x\n", (uint)freq_table);

	return ret;
}

static int proc_mpu_opps_addr_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "0x%x\n", (uint)mpu_opps_addr);

	return ret;
}

static int proc_omap2_clk_init_cpufreq_table_addr_read(char *buffer,
		char **buffer_location, off_t offset, int count, int *eof,
		void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "0x%x\n",
			(uint)SYMSEARCH_GET_ADDRESS(omap2_clk_init_cpufreq_table));

	return ret;
}

static int proc_freq_table_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int i, ret = 0;

	if (offset > 0)
		ret = 0;
	else
		for(i = 0; freq_table[i].frequency != CPUFREQ_TABLE_END; i++) 
		{
			if(ret >= count)
				break;

			ret += scnprintf(buffer+ret, count-ret, "freq_table[%d] index=%u frequency=%u\n", i, freq_table[i].index, freq_table[i].frequency);
		}

	return ret;
}

static int proc_mpu_opps_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int i, ret = 0;

	if (offset > 0)
		ret = 0;
	else
		for(i = MAX_VDD1_OPP; my_mpu_opps[i].rate; i--)
		{
			if(ret >= count)
				break;

			ret += scnprintf(buffer+ret, count-ret, "mpu_opps[%d] rate=%lu opp_id=%u vsel=%u sr_adjust_vsel=%u\n", i,
			my_mpu_opps[i].rate, my_mpu_opps[i].opp_id, my_mpu_opps[i].vsel, my_mpu_opps[i].sr_adjust_vsel);
		}

	return ret;
}

static int proc_mpu_opps_write(struct file *filp, const char __user *buffer,
		unsigned long len, void *data)
{
	uint index, rate, vsel;

	if(!len || len >= BUF_SIZE)
		return -ENOSPC;

	if(copy_from_user(buf, buffer, len))
		return -EFAULT;

	buf[len] = 0;
	
	if(sscanf(buf, "%d %d %d", &index, &rate, &vsel) == 3)
	{
		if (index < 1 || index > MAX_VDD1_OPP)
		{
			printk(KERN_INFO "overclock: invalid index\n");
			return -EFAULT;
		}

		//update mpu_opps
		my_mpu_opps[index].rate = rate;
		my_mpu_opps[index].vsel = vsel;
		my_mpu_opps[index].sr_adjust_vsel = vsel;

		//update frequency table (MAX_VDD1_OPP - index)
		freq_table[MAX_VDD1_OPP - index].frequency = rate / 1000;

		//in case of MAX_VDD1_OPP update max policy
		//and in case of one update min policy
		if (index == MAX_VDD1_OPP)
		{
			policy->max = policy->cpuinfo.max_freq =
			policy->user_policy.max = rate / 1000;
		}
		else if (index == 1)
		{
			policy->min = policy->cpuinfo.min_freq =
			policy->user_policy.min = rate / 1000;
		}
		cpufreq_stats_freq_update(0, MAX_VDD1_OPP - index, rate / 1000);
	}
	else
		printk(KERN_INFO "overclock: insufficient parameters for mpu_opps\n");

	return len;
}

static int proc_version_read(char *buffer, char **buffer_location,
		off_t offset, int count, int *eof, void *data)
{
	int ret;

	if (offset > 0)
		ret = 0;
	else
		ret = scnprintf(buffer, count, "%s\n", DRIVER_VERSION);

	return ret;
}

static int __init overclock_init(void)
{
	struct proc_dir_entry *proc_entry;
	int i;

	printk(KERN_INFO "overclock: %s version %s\n", DRIVER_DESCRIPTION, DRIVER_VERSION);
	printk(KERN_INFO "overclock: by %s\n", DRIVER_AUTHOR);

	SYMSEARCH_BIND_ADDRESS(overclock, omap2_clk_init_cpufreq_table);

	omap2_find_addrs();

	freq_table = (void *)freq_table_addr;
	my_mpu_opps = *(struct omap_opp **)mpu_opps_addr;

	policy = cpufreq_cpu_get(0);
	mpu_clk = clk_get(NULL, MPU_CLK);

	//make sure freq_table has same amount of fields as mpu_opps
	freq_table[MAX_VDD1_OPP].index = MAX_VDD1_OPP;
	freq_table[MAX_VDD1_OPP].frequency = CPUFREQ_TABLE_END;

	for(i = 0; freq_table[i].frequency != CPUFREQ_TABLE_END; i++)
	{}

	for(; i < MAX_VDD1_OPP; i++)
	{
		freq_table[i].index = i;
		freq_table[i].frequency = freq_table[i-1].frequency;
	}

	buf = (char *)vmalloc(BUF_SIZE);

	proc_mkdir("overclock", NULL);
	proc_entry = create_proc_read_entry("overclock/info", 0444, NULL, proc_info_read, NULL);
	proc_entry = create_proc_read_entry("overclock/freq_table_addr", 0444, NULL, proc_freq_table_addr_read, NULL);
	proc_entry = create_proc_read_entry("overclock/mpu_opps_addr", 0444, NULL, proc_mpu_opps_addr_read, NULL);
	proc_entry = create_proc_read_entry("overclock/omap2_clk_init_cpufreq_table_addr", 0444, NULL, proc_omap2_clk_init_cpufreq_table_addr_read, NULL);
	proc_entry = create_proc_read_entry("overclock/freq_table", 0444, NULL, proc_freq_table_read, NULL);
	proc_entry = create_proc_read_entry("overclock/mpu_opps", 0644, NULL, proc_mpu_opps_read, NULL);
	proc_entry->write_proc = proc_mpu_opps_write;
	proc_entry = create_proc_read_entry("overclock/version", 0444, NULL, proc_version_read, NULL);

	return 0;
}

static void __exit overclock_exit(void)
{
	remove_proc_entry("overclock/version", NULL);
	remove_proc_entry("overclock/mpu_opps", NULL);
	remove_proc_entry("overclock/freq_table", NULL);
	remove_proc_entry("overclock/omap2_clk_init_cpufreq_table_addr", NULL);
	remove_proc_entry("overclock/mpu_opps_addr", NULL);
	remove_proc_entry("overclock/info", NULL);
	remove_proc_entry("overclock", NULL);

	vfree(buf);
	printk(KERN_INFO "overclock: removed overclocking and unloaded\n");
}

module_init(overclock_init);
module_exit(overclock_exit);
