How to compile jordan kernel modules
------------------------------------

These external kernel modules require the Defy kernel tree :

It is available at https://github.com/CyanogenDefy/kernel-omap

Add to your repo manifest \<project path="kernel" name="CyanogenDefy/kernel-omap" />

---

"repo sync" and then, in root of your android repo :

    . build/envsetup.sh
    lunch cyanogen_jordan-eng
    
    make kernel
    make jordan_modules

---

PS : Do not make menuconfig, or use make in kernel tree, if you have an error reporting
the kernel source is not clean, type before :

    make kernel_clean

