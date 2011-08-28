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

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>
#define LOG_TAG "CHARGE_ONLY_MODE"
#include <cutils/log.h>

struct asset {
    int w;
    int h;
    const unsigned char *gz;
    int gzlen;
    unsigned short *bits;
};

#include "assets/battery_charge_background.h"
#include "assets/battery_green_img.h"
#include "assets/battery_green_ani.h"
#include "assets/battery_orange_img.h"
#include "assets/battery_orange_ani.h"
#include "assets/battery_red_img.h"
#include "assets/battery_red_ani.h"
#include "assets/ic_pane_battery_charge.h"
#include "assets/ic_pane_battery_complete.h"
#include "assets/ic_pane_battery_error.h"

#include "assets/battery_numbers_0.h"
#include "assets/battery_numbers_1.h"
#include "assets/battery_numbers_2.h"
#include "assets/battery_numbers_3.h"
#include "assets/battery_numbers_4.h"
#include "assets/battery_numbers_5.h"
#include "assets/battery_numbers_6.h"
#include "assets/battery_numbers_7.h"
#include "assets/battery_numbers_8.h"
#include "assets/battery_numbers_9.h"
#include "assets/battery_numbers_percentage.h"

#define FB_WIDTH        480
#define FB_HIGH         854
#define FB_SIZE         FB_WIDTH*FB_HIGH
#define PNG_TOP         71
#define PNG_BOTTOM      318
#define PNG_LEFT        105

static struct asset *battery_numbers_a[] = {
    &battery_numbers_0_a,
    &battery_numbers_1_a,
    &battery_numbers_2_a,
    &battery_numbers_3_a,
    &battery_numbers_4_a,
    &battery_numbers_5_a,
    &battery_numbers_6_a,
    &battery_numbers_7_a,
    &battery_numbers_8_a,
    &battery_numbers_9_a
};

static struct asset *battery_numbers_i[] = {
    &battery_numbers_0_i,
    &battery_numbers_1_i,
    &battery_numbers_2_i,
    &battery_numbers_3_i,
    &battery_numbers_4_i,
    &battery_numbers_5_i,
    &battery_numbers_6_i,
    &battery_numbers_7_i,
    &battery_numbers_8_i,
    &battery_numbers_9_i
};

#include "draw.h"

#define load_asset(a) __load_asset((a),(a)->h,0)
static int __load_asset(struct asset *a, int canvas_h, int y0)
{
    z_stream stream;
    unsigned char *b;

    b = malloc(a->w * canvas_h * 2);
    if (!b) {
        LOGD("Out of memory\n");
        return -1;
    }

    /* Hack for transparent GIFs */
    if (canvas_h != a->h)
        memset(b, 0xff, a->w * canvas_h * 2);

    memset(&stream, 0, sizeof(stream));
    stream.next_in = (unsigned char *)a->gz;
    stream.avail_in = a->gzlen;
    stream.next_out = b + y0*a->w*2;
    stream.avail_out = a->w * a->h * 2;

    if (    inflateInit2(&stream, 31) ||
            inflate(&stream, 1) ||
            inflateEnd(&stream)) {
        LOGD("Unexpected inflate error\n");
        free(b);
        return -1;
    }

    a->bits = (void *)b;
    return 0;
}

static int load_anim_asset(struct asset **_a)
{
    struct asset **a = _a, *a0 = *_a;
    if (load_asset(*a) < 0)
        return -1;
    while (*(++a)) {
        int i;
        /* Frames in transparent GIFs are optimized for size and may be
           shorter than the first. Force them to the same height.
           load_asset will prefill the buffer with 0xff, which will be
           filled in by the transparency code below. */
        if (__load_asset(*a, a0->h, 1) < 0)
            return -1;
        a[0]->h = a[-1]->h;
        /* Patch transparent values in succession */
        for (i=0;i<a[0]->w*a[0]->h;i++)
            if (a[0]->bits[i] == 0xffff)
                a[0]->bits[i] = a[-1]->bits[i];
    }
    return 0;
}

static void unload_asset(struct asset *a)
{
    if (a->bits) free(a->bits);
    a->bits = NULL;
}

static void unload_anim_asset(struct asset **a)
{
    while (*a) {
        unload_asset(*a);
        a++;
    }
}

static void blit(unsigned short *buffer, struct asset *a, int x, int y)
{
    unsigned short *t = buffer + FB_WIDTH*y + x;
    unsigned short *s = a->bits;
    int i;
    for (i=0;i<a->h;i++) {
        memcpy(t, s, a->w * 2);
        s += a->w;
        t += FB_WIDTH;
    }
}

static void ai_blit(unsigned short *buffer, struct asset *_a, struct asset *_i,
        int x, int y)
{
    unsigned char *a = (void *)_a->bits;
    unsigned char *i = (void *)_i->bits;
    unsigned short *t = buffer + FB_WIDTH * y + x;

    for (y=0;y<_i->h;y++) {
        for (x=0;x<_i->w;x++) {
            if (*a == 0)
                ;
            else if (*a == 255)
                *t = ((*i >> 3) << 11) | ((*i >> 2) << 5) | (*i >> 3);
            else {
                int r, g, b;
                r = *t >> 11;
                g = (*t >> 5) & 0x3f;
                b = *t & 0x1f;
                r = ((*i >> 3) * *a + r * (255 - *a)) / 255;
                g = ((*i >> 2) * *a + g * (255 - *a)) / 255;
                b = ((*i >> 3) * *a + b * (255 - *a)) / 255;
                *t = (r << 11) | (g << 5) | b;
            }
            a++; i++; t++;
        }
        t += FB_WIDTH - _i->w;
    }
}

static char draw_initialized = 0;

int draw_init(void)
{
    assert(!draw_initialized);
    if (!  (load_asset(&battery_charge_background) == 0 &&
            load_asset(&battery_green_img) == 0 &&
            load_anim_asset(battery_green_ani) == 0 &&
            load_asset(&battery_orange_img) == 0 &&
            load_anim_asset(battery_orange_ani) == 0 &&
            load_asset(&battery_red_img) == 0 &&
            load_anim_asset(battery_red_ani) == 0 &&
            load_asset(&ic_pane_battery_charge_a) == 0 &&
            load_asset(&ic_pane_battery_charge_i) == 0 &&
            load_asset(&ic_pane_battery_complete_a) == 0 &&
            load_asset(&ic_pane_battery_complete_i) == 0 &&
            load_asset(&ic_pane_battery_error_a) == 0 &&
            load_asset(&ic_pane_battery_error_i) == 0 &&
            load_asset(&battery_numbers_0_a) == 0 &&
            load_asset(&battery_numbers_0_i) == 0 &&
            load_asset(&battery_numbers_1_a) == 0 &&
            load_asset(&battery_numbers_1_i) == 0 &&
            load_asset(&battery_numbers_2_a) == 0 &&
            load_asset(&battery_numbers_2_i) == 0 &&
            load_asset(&battery_numbers_3_a) == 0 &&
            load_asset(&battery_numbers_3_i) == 0 &&
            load_asset(&battery_numbers_4_a) == 0 &&
            load_asset(&battery_numbers_4_i) == 0 &&
            load_asset(&battery_numbers_5_a) == 0 &&
            load_asset(&battery_numbers_5_i) == 0 &&
            load_asset(&battery_numbers_6_a) == 0 &&
            load_asset(&battery_numbers_6_i) == 0 &&
            load_asset(&battery_numbers_7_a) == 0 &&
            load_asset(&battery_numbers_7_i) == 0 &&
            load_asset(&battery_numbers_8_a) == 0 &&
            load_asset(&battery_numbers_8_i) == 0 &&
            load_asset(&battery_numbers_9_a) == 0 &&
            load_asset(&battery_numbers_9_i) == 0 &&
            load_asset(&battery_numbers_percentage_a) == 0 &&
            load_asset(&battery_numbers_percentage_i) == 0))
        goto error;

    draw_initialized = 1;
    return 0;

error:
    draw_uninit();
    return -1;
}

void draw_uninit(void)
{
    unload_asset(&battery_charge_background);
    unload_asset(&battery_green_img);
    unload_anim_asset(battery_green_ani);
    unload_asset(&battery_orange_img);
    unload_anim_asset(battery_orange_ani);
    unload_asset(&battery_red_img);
    unload_anim_asset(battery_red_ani);
    unload_asset(&ic_pane_battery_charge_a);
    unload_asset(&ic_pane_battery_charge_i);
    unload_asset(&ic_pane_battery_complete_a);
    unload_asset(&ic_pane_battery_complete_i);
    unload_asset(&ic_pane_battery_error_a);
    unload_asset(&ic_pane_battery_error_i);
    unload_asset(&battery_numbers_0_a);
    unload_asset(&battery_numbers_0_i);
    unload_asset(&battery_numbers_1_a);
    unload_asset(&battery_numbers_1_i);
    unload_asset(&battery_numbers_2_a);
    unload_asset(&battery_numbers_2_i);
    unload_asset(&battery_numbers_3_a);
    unload_asset(&battery_numbers_3_i);
    unload_asset(&battery_numbers_4_a);
    unload_asset(&battery_numbers_4_i);
    unload_asset(&battery_numbers_5_a);
    unload_asset(&battery_numbers_5_i);
    unload_asset(&battery_numbers_6_a);
    unload_asset(&battery_numbers_6_i);
    unload_asset(&battery_numbers_7_a);
    unload_asset(&battery_numbers_7_i);
    unload_asset(&battery_numbers_8_a);
    unload_asset(&battery_numbers_8_i);
    unload_asset(&battery_numbers_9_a);
    unload_asset(&battery_numbers_9_i);
    unload_asset(&battery_numbers_percentage_a);
    unload_asset(&battery_numbers_percentage_i);

    draw_initialized = 0;
}

void draw(int w, int h, unsigned short *color_channel, int percent, int error)
{
    struct asset *desired_ic_pane_a, *desired_ic_pane_i;
    static int frame = 0;
    struct asset *battery_img, *battery_ani;

    if (percent < 10) {
        battery_img = &battery_red_img;
        battery_ani = battery_red_ani[frame % 4];
    } else if (percent < 30) {
        battery_img = &battery_orange_img;
        battery_ani = battery_orange_ani[frame % 4];
    } else {
        battery_img = &battery_green_img;
        battery_ani = battery_green_ani[frame % 4];
    }

    if (error) {
        desired_ic_pane_a = &ic_pane_battery_error_a;
        desired_ic_pane_i = &ic_pane_battery_error_i;
    } else if (percent < 100) {
        desired_ic_pane_a = &ic_pane_battery_charge_a;
        desired_ic_pane_i = &ic_pane_battery_charge_i;
    } else {
        desired_ic_pane_a = &ic_pane_battery_complete_a;
        desired_ic_pane_i = &ic_pane_battery_complete_i;
    }

    memset(color_channel, 0, FB_WIDTH * FB_HIGH * 2);
    blit(color_channel, &battery_charge_background,
                (FB_WIDTH - battery_charge_background.w) / 2,
                (FB_HIGH - battery_charge_background.h) / 2);

    /* Fill it up! */
    if (!error) {
        int top = PNG_TOP + (FB_HIGH-battery_charge_background.h) / 2;
        int bottom = PNG_BOTTOM + (FB_HIGH - battery_charge_background.h) / 2;
        int left = PNG_LEFT + (FB_WIDTH - battery_charge_background.w) / 2;
        int fill_height_pixels = percent * (bottom - top) / 100;
        unsigned short *s, *t;
        int y;

        y = bottom - fill_height_pixels;
        t = color_channel + FB_WIDTH * y + left;
        for (;y<bottom;y++) {
            memcpy(t, battery_img->bits, battery_img->w * 2);
            t += FB_WIDTH;
        }

        y = bottom - fill_height_pixels - battery_ani->h;
        if (y < top)
            y = top;
        bottom = y + battery_ani->h;
        t = color_channel + FB_WIDTH * y + left;
        s = (void *)battery_ani->bits;
        if (percent < 100)
            for (;y<bottom;y++) {
                memcpy(t, s, battery_ani->w * 2);
                s += battery_ani->w;
                t += FB_WIDTH;
            }
    }

    /* Compose battery indicator */
    ai_blit(color_channel, desired_ic_pane_a, desired_ic_pane_i,
            (FB_WIDTH - desired_ic_pane_i->w) / 2, (FB_HIGH - desired_ic_pane_i->h) / 2);

    /* Draw percentage */
    if (!error) {
        unsigned char s[3];
        int digits = 0;
        int w, x, y, i;
        if (percent == 100) s[digits++] = 1;
        if (percent >= 10) s[digits++] = (percent / 10) % 10;
        s[digits++] = percent % 10;
        w = battery_numbers_i[0]->w + 2;
        x = (FB_WIDTH - digits * w) / 2 + 1;
        y = (FB_HIGH + battery_charge_background.h) / 2;
        for (i=0;i<digits;i++)
            ai_blit(color_channel, battery_numbers_a[s[i]],
                    battery_numbers_i[s[i]], x + i*w, y);
        ai_blit(color_channel, &battery_numbers_percentage_a,
                &battery_numbers_percentage_i, x + i*w, y);
    }

    frame++;
}
