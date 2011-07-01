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

#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/poll.h>

#include <linux/input.h>

#include <sys/socket.h>
#include <sys/un.h>
#include <linux/netlink.h>

#include "events.h"
#include "hardware.h"
#define LOG_TAG "CHARGE_ONLY_MODE"
#include <cutils/log.h>
#include <string.h>

#define MAX_DEVICES 16

static struct pollfd ev_fds[MAX_DEVICES];
static int ev_count = 0;
static enum { EV_TYPE_UNKNOWN, EV_TYPE_KEYBOARD, EV_TYPE_UEVENT } ev_type[MAX_DEVICES];

#define EV_POWER_KEY_CODE KEY_END
#define EV_VOLUMEDOWN_KEY_CODE   KEY_VOLUMEDOWN
#define EV_VOLUMEUP_KEY_CODE     KEY_VOLUMEUP
#define EV_CAMERA_KEY_CODE       KEY_CAMERA

#define EV_KEY_VALUE_DOWN 0x01
#define EV_KEY_VALUE_UP 0x00

struct uevent {
    const char *action;
    const char *path;
    const char *subsystem;
    const char *firmware;
    int major;
    int minor;
};

static int open_uevent_socket(void)
{
    struct sockaddr_nl addr;
    int sz = 64*1024;
    int s;

    memset(&addr, 0, sizeof(addr));
    addr.nl_family = AF_NETLINK;
    addr.nl_pid = getpid();
    addr.nl_groups = 0xffffffff;

    s = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_KOBJECT_UEVENT);
    if(s < 0)
        return -1;

    setsockopt(s, SOL_SOCKET, SO_RCVBUFFORCE, &sz, sizeof(sz));

    if(bind(s, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
        close(s);
        return -1;
    }

    return s;
}

int ev_init(void)
{
    int fd;

    int i;
    for (i=0;;i++) {
        char fname[32];
        sprintf(fname, "/dev/input/event%d", i);
        fd = open(fname, O_RDONLY);
        if (fd < 0)
            break;
        ev_type[ev_count] = EV_TYPE_KEYBOARD;
        ev_fds[ev_count].fd = fd;
        ev_fds[ev_count].events = POLLIN;
        ev_count++;
    }

    fd = open_uevent_socket();
    if (fd >= 0) {
        fcntl(fd, F_SETFD, FD_CLOEXEC);
        fcntl(fd, F_SETFL, O_NONBLOCK);
        ev_type[ev_count] = EV_TYPE_UEVENT;
        ev_fds[ev_count].fd = fd;
        ev_fds[ev_count].events = POLLIN;
        ev_count++;
    }

    return 0;
}

void ev_exit(void)
{
    while (ev_count-- > 0) {
        close(ev_fds[ev_count].fd);
    }
}

int ev_get(int timeout_ms)
{
    int r, i;

    r = poll(ev_fds, ev_count, timeout_ms);
    if (r <= 0)
        return -1;

    for (i=0;i<ev_count;i++) {
        if ((ev_fds[i].revents & POLLIN) == 0)
            continue;

        if (ev_type[i] == EV_TYPE_KEYBOARD) {
            struct input_event ev;
            r = read(ev_fds[i].fd, &ev, sizeof(ev));
            fprintf(stderr, "keyboard event: (%x,%x,%x)\n", ev.type, ev.code, ev.value);
            if(r == sizeof(ev)) {

                /* POWER key */
                if ((ev.type == EV_KEY) && (ev.code == EV_POWER_KEY_CODE) && (ev.value == EV_KEY_VALUE_DOWN))
                    return EVENT_POWER_KEY_DOWN;
                if ((ev.type == EV_KEY) && (ev.code == EV_POWER_KEY_CODE) && (ev.value == EV_KEY_VALUE_UP))
                    return EVENT_POWER_KEY_UP;

                /* VOLUMEDOWN key */
                if ((ev.type == EV_KEY) && (ev.code == EV_VOLUMEDOWN_KEY_CODE) && (ev.value == EV_KEY_VALUE_DOWN))
                    return EVENT_VOLUMEDOWN_KEY_DOWN;
                if ((ev.type == EV_KEY) && (ev.code == EV_VOLUMEDOWN_KEY_CODE) && (ev.value == EV_KEY_VALUE_UP))
                    return EVENT_VOLUMEDOWN_KEY_UP;

                /* VOLUMEUP key */
                if ((ev.type == EV_KEY) && (ev.code == EV_VOLUMEUP_KEY_CODE) && (ev.value == EV_KEY_VALUE_DOWN))
                    return EVENT_VOLUMEUP_KEY_DOWN;
                if ((ev.type == EV_KEY) && (ev.code == EV_VOLUMEUP_KEY_CODE) && (ev.value == EV_KEY_VALUE_UP))
                    return EVENT_VOLUMEUP_KEY_UP;

                /* CAMERA key */
                if ((ev.type == EV_KEY) && (ev.code == EV_CAMERA_KEY_CODE) && (ev.value == EV_KEY_VALUE_DOWN))
                    return EVENT_CAMERA_KEY_DOWN;
                if ((ev.type == EV_KEY) && (ev.code == EV_CAMERA_KEY_CODE) && (ev.value == EV_KEY_VALUE_UP))
                    return EVENT_CAMERA_KEY_UP;

                return -1;
            }
        } else if (ev_type[i] == EV_TYPE_UEVENT) {

            char msg[1024];
            while ((r = recv(ev_fds[i].fd, msg, sizeof(msg), 0)) > 0)
                ;
            if(strstr(msg, "cpcap_battery"))
            {
                LOGD("cpcap_battery UEVENT msg : %s\n", msg);
                return EVENT_BATTERY;
            }

        }
    }

    return -1;
}
