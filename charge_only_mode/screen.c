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
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <linux/fb.h>
#include <linux/kd.h>

#include "draw.h"

#define LOG_TAG "CHARGE_ONLY_MODE"
#include <cutils/log.h>

struct FB {
    unsigned short *bits;
    unsigned size;
    int fd;
    struct fb_fix_screeninfo fi;
    struct fb_var_screeninfo vi;
};

#define fb_width(fb) ((fb)->vi.xres)
#define fb_height(fb) ((fb)->vi.yres)
#define fb_size(fb) ((fb)->vi.xres * (fb)->vi.yres * 2)

static int vt_set_mode(int graphics)
{
    int fd, r;
    fd = open("/dev/tty0", O_RDWR | O_SYNC);
    if (fd < 0)
        return -1;
    r = ioctl(fd, KDSETMODE, (void*) (graphics ? KD_GRAPHICS : KD_TEXT));
    close(fd);
    return r;
}

static int fb_open(struct FB *fb)
{
    /* Switch to graphics mode */
    vt_set_mode(1);

    fb->fd = open("/dev/graphics/fb0", O_RDWR);
    if (fb->fd < 0)
    {
    LOGD("fb open failed!\n");
        return -1;
    }
    if (ioctl(fb->fd, FBIOGET_FSCREENINFO, &fb->fi) < 0)
    {
    LOGD("fb ioctl FBIOGET_FSCREENINFO failed \n");
        goto err1;
    }
    if (ioctl(fb->fd, FBIOGET_VSCREENINFO, &fb->vi) < 0)
    {
    LOGD("fb ioctl FBIOGET_VSCREENINFO failed \n");
        goto err1;
    }

    fb->bits = mmap(0, fb->fi.smem_len, PROT_READ | PROT_WRITE,
                    MAP_SHARED, fb->fd, 0);
    if (fb->bits == MAP_FAILED)
    {
        LOGD("fb mapping failed!\n");
            goto err1;
    }
    return 0;

err1:
    close(fb->fd);
    return -1;
}

static void fb_close(struct FB *fb)
{
    munmap(fb->bits, fb_size(fb));
    close(fb->fd);
}

static struct FB __fb, *fb = &__fb;
static int mode;

int screen_init(void)
{
    if (draw_init())
        goto err1;
    if (fb_open(fb))
        goto err2;
    return 0;

err2:
    draw_uninit();
err1:
    return -1;
}

#define ASSERT(x) do { if (!(x)) *(int *)0=0; } while (0)

int screen_update(int percentage, int error)
{
    fb->vi.yres_virtual = fb->vi.yres * 2;
    fb->vi.yoffset = fb->vi.yoffset ? 0 : fb->vi.yres;
    fb->vi.bits_per_pixel = 16;
    draw(fb_width(fb), fb_height(fb), fb->bits + fb->vi.yoffset * fb_width(fb),
            percentage, error);
    ioctl(fb->fd, FBIOPUT_VSCREENINFO, &fb->vi);

    return 0;
}

/* 565RLE image format: [count(2 bytes), rle(2 bytes)] */

static int show_565rle(const char *fn)
{
    struct stat s;
    unsigned short *data, *bits, *ptr;
    unsigned count, max;
    int fd;

    fd = open(fn, O_RDONLY);
    if (fd < 0) {
        LOGD("cannot open '%s'\n", fn);
        goto err1;
    }

    if (fstat(fd, &s) < 0)
        goto err2;

    data = mmap(0, s.st_size, PROT_READ, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED)
        goto err2;

    max = fb_width(fb) * fb_height(fb);
    ptr = data;
    count = s.st_size;
    bits = fb->bits;
    while (count > 3) {
        unsigned n = ptr[0];
        if (n > max)
            break;
        max -= n;
        while (n--)
            *(bits++) = ptr[1];
        ptr += 2;
        count -= 4;
    }

    /* replicate on both pages */
    memcpy(fb->bits + fb->vi.yres * fb_width(fb), fb->bits,
            fb_width(fb) * fb_height(fb) * 2);

    fb->vi.yres_virtual = fb->vi.yres * 2;
    fb->vi.yoffset = fb->vi.yoffset ? 0 : fb->vi.yres;  /* force a flip */
    fb->vi.bits_per_pixel = 16;
    ioctl(fb->fd, FBIOPUT_VSCREENINFO, &fb->vi);

    munmap(data, s.st_size);
    close(fd);
    return 0;

err2:
    close(fd);
err1:
    return -1;
}

void screen_uninit(void)
{
    show_565rle("/initlogo.rle");
    fb_close(fb);
    draw_uninit();
}

void display_blank(void)
{
   if (ioctl(fb->fd, FBIOBLANK, VESA_POWERDOWN) < 0)
       LOGD("display blank failed, fb.fd %d\n", fb->fd);
}

void display_unblank(void)
{
   if (ioctl(fb->fd, FBIOBLANK, VESA_NO_BLANKING) < 0)
       LOGD("display unblank failed, fb.fd %d\n", fb->fd);
}
