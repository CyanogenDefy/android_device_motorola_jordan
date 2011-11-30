/*
 * Fake module to prevent BattStats/NetworkStats FC related to network usage in ICS
 *
 * (C) 2011 Tanguy Pruvot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#include <linux/module.h>
#include <linux/skbuff.h>
#include <linux/file.h>
#include <net/sock.h>
#include <linux/netfilter/x_tables.h>
#include <linux/netfilter/xt_owner.h>

#include <linux/proc_fs.h>

#define TAG "xt_qtaguid"
static struct proc_dir_entry *proc_root = NULL;

/*
 * Maximum number of socket tags that a UID is allowed to have active.
 * Multiple processes belonging to the same UID contribute towards this limit.
 * Special UIDs that can impersonate a UID also contribute (e.g. download
 * manager, ...)
 */
#define DEFAULT_MAX_SOCK_TAGS 1024

/*
 * For now we only track 2 sets of counters.
 * The default set is 0.
 * Userspace can activate another set for a given uid being tracked.
 */
#define IFS_MAX_COUNTER_SETS 2

static bool
qta_owner_mt(const struct sk_buff *skb, const struct xt_match_param *par)
{
	const struct xt_owner_match_info *info = par->matchinfo;
	const struct file *filp;

	if (skb->sk == NULL || skb->sk->sk_socket == NULL)
		return (info->match ^ info->invert) == 0;
	else if (info->match & info->invert & XT_OWNER_SOCKET)
		/*
		 * Socket exists but user wanted ! --socket-exists.
		 * (Single ampersands intended.)
		 */
		return false;

	filp = skb->sk->sk_socket->file;
	if (filp == NULL)
		return ((info->match ^ info->invert) &
			   (XT_OWNER_UID | XT_OWNER_GID)) == 0;

	if (info->match & XT_OWNER_UID)
		if ((filp->f_cred->fsuid >= info->uid_min &&
			filp->f_cred->fsuid <= info->uid_max) ^
			!(info->invert & XT_OWNER_UID))
			return false;

	if (info->match & XT_OWNER_GID)
		if ((filp->f_cred->fsgid >= info->gid_min &&
			filp->f_cred->fsgid <= info->gid_max) ^
			!(info->invert & XT_OWNER_GID))
			return false;

	return true;
}

struct qta_proc_print_info {
	char *outp;
	char **num_items_returned;
	struct iface_stat *iface_entry;
	struct tag_stat *ts_entry;
	int item_index;
	int items_to_skip;
	int char_count;
};

static int qta_pp_stats_line(struct qta_proc_print_info *ppi, int cnt_set)
{
	int len;
	if (!ppi->item_index) {
		if (ppi->item_index++ < ppi->items_to_skip)
			return 0;
		/*
		len = snprintf(ppi->outp, ppi->char_count,
		       "idx iface acct_tag_hex uid_tag_int cnt_set "
		       "rx_bytes rx_packets "
		       "tx_bytes tx_packets "
		       "rx_tcp_packets rx_tcp_bytes "
		       "rx_udp_packets rx_udp_bytes "
		       "rx_other_packets rx_other_bytes "
		       "tx_tcp_packets tx_tcp_bytes "
		       "tx_udp_packets tx_udp_bytes "
		       "tx_other_packets tx_other_bytes\n");
		*/
		len = snprintf(ppi->outp, ppi->char_count, "0\n");
	} else {
		//...
		if (ppi->item_index++ < ppi->items_to_skip)
			return 0;
		len = snprintf(ppi->outp, ppi->char_count, "0\n");
	}
/*		len = snprintf(
			ppi->outp, ppi->char_count,
			"%d %s 0x%llx %u %u "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu "
			"%llu %llu\n",
			ppi->item_index,
			ppi->iface_entry->ifname,
			get_atag_from_tag(tag),
			stat_uid,
			cnt_set,
			dc_sum_bytes(cnts, cnt_set, IFS_RX),
			dc_sum_packets(cnts, cnt_set, IFS_RX),
			dc_sum_bytes(cnts, cnt_set, IFS_TX),
			dc_sum_packets(cnts, cnt_set, IFS_TX),
			cnts->bpc[cnt_set][IFS_RX][IFS_TCP].bytes,
			cnts->bpc[cnt_set][IFS_RX][IFS_TCP].packets,
			cnts->bpc[cnt_set][IFS_RX][IFS_UDP].bytes,
			cnts->bpc[cnt_set][IFS_RX][IFS_UDP].packets,
			cnts->bpc[cnt_set][IFS_RX][IFS_PROTO_OTHER].bytes,
			cnts->bpc[cnt_set][IFS_RX][IFS_PROTO_OTHER].packets,
			cnts->bpc[cnt_set][IFS_TX][IFS_TCP].bytes,
			cnts->bpc[cnt_set][IFS_TX][IFS_TCP].packets,
			cnts->bpc[cnt_set][IFS_TX][IFS_UDP].bytes,
			cnts->bpc[cnt_set][IFS_TX][IFS_UDP].packets,
			cnts->bpc[cnt_set][IFS_TX][IFS_PROTO_OTHER].bytes,
			cnts->bpc[cnt_set][IFS_TX][IFS_PROTO_OTHER].packets);
*/
	return len;
}

bool qta_pp_sets(struct qta_proc_print_info *ppi)
{
	int len;
	int counter_set;
	for (counter_set = 0; counter_set < IFS_MAX_COUNTER_SETS;
	     counter_set++) {
		len = qta_pp_stats_line(ppi, counter_set);
		if (len >= ppi->char_count) {
			*ppi->outp = '\0';
			return false;
		}
		if (len) {
			ppi->outp += len;
			ppi->char_count -= len;
			(*ppi->num_items_returned)++;
		}
	}
	return true;
}

static int proc_stats_read(char *page, char **num_items_returned, off_t items_to_skip, int char_count, int *eof, void *data) {
	int len;
	struct qta_proc_print_info ppi;

	ppi.outp = page;
	ppi.item_index = 0;
	ppi.char_count = char_count;
	ppi.num_items_returned = num_items_returned;
	ppi.items_to_skip = items_to_skip;

	printk(KERN_DEBUG TAG":proc stats page=%p *num_items_returned=%p off=%ld "
		"char_count=%d *eof=%d\n", page, *num_items_returned,
		items_to_skip, char_count, *eof);

	if (*eof)
		return 0;

	/* The idx is there to help debug when things go belly up. */
	len = qta_pp_stats_line(&ppi, 0);
	/* Don't advance the outp unless the whole line was printed */
	if (len >= ppi.char_count) {
		*ppi.outp = '\0';
		return ppi.outp - page;
	}
	if (len) {
		ppi.outp += len;
		ppi.char_count -= len;
		(*num_items_returned)++;
	}

	*eof = 1;
	return ppi.outp - page;
}

static int qta_ctrl_parse(const char *input, int count)
{
	char cmd;
	int res=0;

	printk(KERN_INFO TAG": ctrl=%s\n", input);

	cmd = input[0];
	/* Collect params for commands */
	switch (cmd) {
	case 'd':
		//res = ctrl_cmd_delete(input);
		break;
	case 's':
		//res = ctrl_cmd_counter_set(input);
		break;
	case 't':
		//res = ctrl_cmd_tag(input);
		break;
	case 'u':
		//res = ctrl_cmd_untag(input);
		break;

	default:
		res = -EINVAL;
		goto err;
	}
	if (!res)
		res = count;
err:
	printk(KERN_ERR TAG": ctrl(%s): res=%d\n", input, res);
	return res;
}

#define MAX_QTAGUID_CTRL_INPUT_LEN 255
static int proc_ctrl_write(struct file *filp, const char __user *buffer, unsigned long count, void *data) {

	char input_buf[MAX_QTAGUID_CTRL_INPUT_LEN];

	if (count >= MAX_QTAGUID_CTRL_INPUT_LEN)
		return -EINVAL;

	if (copy_from_user(input_buf, buffer, count))
		return -EFAULT;

	input_buf[count] = '\0';
	return qta_ctrl_parse(input_buf, count);
}

static struct xt_match qta_owner_mt_reg __read_mostly = {
	.name       = "owner",
	.revision   = 1,
	.family     = NFPROTO_UNSPEC,
	.match      = qta_owner_mt,
	.matchsize  = sizeof(struct xt_owner_match_info),
	.hooks      = (1 << NF_INET_LOCAL_OUT) |
	              (1 << NF_INET_POST_ROUTING),
	.me         = THIS_MODULE,
};

static int __init qta_owner_mt_init(void)
{
	struct proc_dir_entry *proc_entry;

	proc_root = proc_mkdir("xt_qtaguid", init_net.proc_net);

	if (proc_root) {
		proc_entry = create_proc_read_entry("ctrl", 0622, proc_root, NULL, NULL);
		proc_entry->write_proc = proc_ctrl_write;
		proc_entry = create_proc_read_entry("stats", 0444, proc_root, proc_stats_read, NULL);
	}
	else {
		printk(KERN_ERR TAG ": unable to create /proc/self/net/xt_qtaguid");
		return -1;
	}

	return xt_register_match(&qta_owner_mt_reg);
}

static void __exit qta_owner_mt_exit(void)
{
	if (proc_root) {
		remove_proc_entry("ctrl", proc_root);
		remove_proc_entry("stats", proc_root);
		remove_proc_entry("xt_qtaguid", init_net.proc_net);
	}
	xt_unregister_match(&qta_owner_mt_reg);
}

module_init(qta_owner_mt_init);
module_exit(qta_owner_mt_exit);

MODULE_AUTHOR("Tanguy Pruvot");
MODULE_DESCRIPTION("Xtables: socket owner match to xt_qtaguid");
MODULE_LICENSE("GPL");
MODULE_VERSION("0.3");
MODULE_ALIAS("ipt_qtaguid");
MODULE_ALIAS("ip6t_qtaguid");
