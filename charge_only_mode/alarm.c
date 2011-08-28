/**************************************************************************************************
Copyright (c) 2008-2011, Motorola, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this list of conditions
  and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions
  and the following disclaimer in the documentation and/or other materials provided with the
  distribution.
- Neither the name of the Motorola, Inc. nor the names of its contributors may be used to endorse or
  promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "alarm.h"
#define LOG_TAG "CHARGE_ONLY_MODE"
#include <cutils/log.h>

struct alarm_node
{
    struct alarm_node *next;
    struct timeval alarm_time;
    void (*f)(void *);
    void *cookie;
};

static struct alarm_node *alarms = NULL;

void alarm_process(void)
{
    struct alarm_node *a;
    struct timeval now;
    gettimeofday(&now, NULL);

    while ((a = alarms) != NULL) {
        if (now.tv_sec < a->alarm_time.tv_sec)
            break;
        if (    (now.tv_sec == a->alarm_time.tv_sec)  &&
                (now.tv_usec < a->alarm_time.tv_usec))
            break;
        alarms = a->next;

        (a->f)(a->cookie);
        free(a);
    }
}

int alarm_get_time_until_next(void)
{
    struct timeval now;
    int delta;
    if (!alarms)
        return 0x7fffffff;
    gettimeofday(&now, NULL);
    delta = (alarms->alarm_time.tv_sec - now.tv_sec) * 1000 +
            (alarms->alarm_time.tv_usec - now.tv_usec) / 1000;
    LOGD("alarm_get_time_until_next, delta = %d\n", delta);
    return delta;
}

int alarm_set_relative(void (*f)(void *), void *cookie, int ms)
{
    struct alarm_node *p, *c, *a = malloc(sizeof(*a));
    if (!a)
        return -1;
    a->next = NULL;
    gettimeofday(&a->alarm_time, NULL);
    a->alarm_time.tv_usec += ms * 1000;
    if (a->alarm_time.tv_usec >= 1000000) {
        a->alarm_time.tv_sec += (a->alarm_time.tv_usec / 1000000);
        a->alarm_time.tv_usec %= 1000000;
    }
    a->f = f;
    a->cookie = cookie;

    p = NULL;
    c = alarms;
    while (c) {
        if (c->alarm_time.tv_sec > a->alarm_time.tv_sec)
            break;
        if (    (c->alarm_time.tv_sec == a->alarm_time.tv_sec)  &&
                (c->alarm_time.tv_usec > a->alarm_time.tv_usec))
            break;

        p = c;
        c = c->next;
    }

    if (!p) {
        a->next = alarms;
        alarms = a;
    } else {
        a->next = p->next;
        p->next = a;
    }
    return 0;
}

int alarm_cancel(void (*f)(void *))
{
    struct alarm_node *p, *c;
    int cancelled = 0;
    p = NULL;
    c = alarms;
    while (c) {
        if (c->f == f) {
            struct alarm_node *a = c;
            if (p)
                p->next = c->next;
            else
                alarms = c->next;
            c = c->next;
            free(a);
            cancelled++;
            continue;
        }
        p = c;
        c = c->next;
    }
    return cancelled;
}
