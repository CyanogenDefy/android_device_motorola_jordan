all: exe copy

exe:
	cd ~/a ; make -j8 out/target/product/morrison/obj/EXECUTABLES/charge_only_mode_intermediates/charge_only_mode ; cd -

copy:
	adb push ~/a/out/target/product/morrison/obj/EXECUTABLES/charge_only_mode_intermediates/charge_only_mode data/com
