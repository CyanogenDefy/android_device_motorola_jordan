/*
 * hook - Hook utilities.
 *
 * Copyright (C) 2010 Nothize
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#ifndef _HOOK_H_
#define _HOOK_H_

struct hook_info {
	unsigned int asm0;
	unsigned int jmp;
	unsigned int *target_cont;
	unsigned int *target;
	char *targetName;
	unsigned int newfunc;
};

int hook(struct hook_info *);

int unhook(struct hook_info *);

int hook_init(void);
void hook_exit(void);

extern struct hook_info g_hi[];

#define HOOK_INVOKE(_f, ...) ((typeof(&_f))&g_hi[__COUNTER__].asm0)(__VA_ARGS__)

#define HOOK_INIT(f) { .targetName = #f, .newfunc = (unsigned int)f }

#define HOOK_INIT_END { .newfunc = 0 }

#endif
