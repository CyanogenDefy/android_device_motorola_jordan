/*
 * logcap - cpcap io sniffer module for Motorola Defy
 *
 * hooking taken from "n - for testing kernel function hooking" by Nothize
 * require symsearch module by Skrilaz
 *
 * Copyright (C) 2011 CyanogenDefy
 *
 */

#define TAG "logcap"

#include <linux/spi/spi.h>
#include <linux/spi/cpcap.h>
#include <linux/spi/cpcap-regbits.h>

struct regname {
	short reg;
	const char * name;
};

static const struct regname regnames[] = {
	{ CPCAP_REG_INT1     , "INT1"      }, /* Interrupt 1 */
	{ CPCAP_REG_INT2     , "INT2"      }, /* Interrupt 2 */
	{ CPCAP_REG_INT3     , "INT3"      }, /* Interrupt 3 */
	{ CPCAP_REG_INT4     , "INT4"      }, /* Interrupt 4 */
	{ CPCAP_REG_INTM1    , "INTM1"     }, /* Interrupt Mask 1 */
	{ CPCAP_REG_INTM2    , "INTM2"     }, /* Interrupt Mask 2 */
	{ CPCAP_REG_INTM3    , "INTM3"     }, /* Interrupt Mask 3 */
	{ CPCAP_REG_INTM4    , "INTM4"     }, /* Interrupt Mask 4 */
	{ CPCAP_REG_INTS1    , "INTS1"     }, /* Interrupt Sense 1 */
	{ CPCAP_REG_INTS2    , "INTS2"     }, /* Interrupt Sense 2 */
	{ CPCAP_REG_INTS3    , "INTS3"     }, /* Interrupt Sense 3 */
	{ CPCAP_REG_INTS4    , "INTS4"     }, /* Interrupt Sense 4 */
	{ CPCAP_REG_ASSIGN1  , "ASSIGN1"   }, /* Resource Assignment 1 */
	{ CPCAP_REG_ASSIGN2  , "ASSIGN2"   }, /* Resource Assignment 2 */
	{ CPCAP_REG_ASSIGN3  , "ASSIGN3"   }, /* Resource Assignment 3 */
	{ CPCAP_REG_ASSIGN4  , "ASSIGN4"   }, /* Resource Assignment 4 */
	{ CPCAP_REG_ASSIGN5  , "ASSIGN5"   }, /* Resource Assignment 5 */
	{ CPCAP_REG_ASSIGN6  , "ASSIGN6"   }, /* Resource Assignment 6 */
	{ CPCAP_REG_VERSC1   , "VERSC1"    }, /* Version Control 1 */
	{ CPCAP_REG_VERSC2   , "VERSC2"    }, /* Version Control 2 */
	{ CPCAP_REG_MI1      , "MI1"       }, /* Macro Interrupt 1 */
	{ CPCAP_REG_MIM1     , "MIM1"      }, /* Macro Interrupt Mask 1 */
	{ CPCAP_REG_MI2      , "MI2"       }, /* Macro Interrupt 2 */
	{ CPCAP_REG_MIM2     , "MIM2"      }, /* Macro Interrupt Mask 2 */
	{ CPCAP_REG_UCC1     , "UCC1"      }, /* UC Control 1 */
	{ CPCAP_REG_UCC2     , "UCC2"      }, /* UC Control 2 */
	{ CPCAP_REG_PC1      , "PC1"       }, /* Power Cut 1 */
	{ CPCAP_REG_PC2      , "PC2"       }, /* Power Cut 2 */
	{ CPCAP_REG_BPEOL    , "BPEOL"     }, /* BP and EOL */
	{ CPCAP_REG_PGC      , "PGC"       }, /* Power Gate and Control */
	{ CPCAP_REG_MT1      , "MT1"       }, /* Memory Transfer 1 */
	{ CPCAP_REG_MT2      , "MT2"       }, /* Memory Transfer 2 */
	{ CPCAP_REG_MT3      , "MT3"       }, /* Memory Transfer 3 */
	{ CPCAP_REG_PF       , "PF"        }, /* Print Format */
	{ CPCAP_REG_SCC      , "SCC"       }, /* System Clock Control */
	{ CPCAP_REG_SW1      , "SW1"       }, /* Stop Watch 1 */
	{ CPCAP_REG_SW2      , "SW2"       }, /* Stop Watch 2 */
	{ CPCAP_REG_UCTM     , "UCTM"      }, /* UC Turbo Mode */
	{ CPCAP_REG_TOD1     , "TOD1"      }, /* Time of Day 1 */
	{ CPCAP_REG_TOD2     , "TOD2"      }, /* Time of Day 2 */
	{ CPCAP_REG_TODA1    , "TODA1"     }, /* Time of Day Alarm 1 */
	{ CPCAP_REG_TODA2    , "TODA2"     }, /* Time of Day Alarm 2 */
	{ CPCAP_REG_DAY      , "DAY"       }, /* Day */
	{ CPCAP_REG_DAYA     , "DAYA"      }, /* Day Alarm */
	{ CPCAP_REG_VAL1     , "VAL1"      }, /* Validity 1 */
	{ CPCAP_REG_VAL2     , "VAL2"      }, /* Validity 2 */
	{ CPCAP_REG_SDVSPLL  , "SDVSPLL"   }, /* Switcher DVS and PLL */
	{ CPCAP_REG_SI2CC1   , "SI2CC1"    }, /* Switcher I2C Control 1 */
	{ CPCAP_REG_Si2CC2   , "Si2CC2"    }, /* Switcher I2C Control 2 */
	{ CPCAP_REG_S1C1     , "S1C1"      }, /* Switcher 1 Control 1 */
	{ CPCAP_REG_S1C2     , "S1C2"      }, /* Switcher 1 Control 2 */
	{ CPCAP_REG_S2C1     , "S2C1"      }, /* Switcher 2 Control 1 */
	{ CPCAP_REG_S2C2     , "S2C2"      }, /* Switcher 2 Control 2 */
	{ CPCAP_REG_S3C      , "S3C"       }, /* Switcher 3 Control */
	{ CPCAP_REG_S4C1     , "S4C1"      }, /* Switcher 4 Control 1 */
	{ CPCAP_REG_S4C2     , "S4C2"      }, /* Switcher 4 Control 2 */
	{ CPCAP_REG_S5C      , "S5C"       }, /* Switcher 5 Control */
	{ CPCAP_REG_S6C      , "S6C"       }, /* Switcher 6 Control */
	{ CPCAP_REG_VCAMC    , "VCAMC"     }, /* VCAM Control */
	{ CPCAP_REG_VCSIC    , "VCSIC"     }, /* VCSI Control */
	{ CPCAP_REG_VDACC    , "VDACC"     }, /* VDAC Control */
	{ CPCAP_REG_VDIGC    , "VDIGC"     }, /* VDIG Control */
	{ CPCAP_REG_VFUSEC   , "VFUSEC"    }, /* VFUSE Control */
	{ CPCAP_REG_VHVIOC   , "VHVIOC"    }, /* VHVIO Control */
	{ CPCAP_REG_VSDIOC   , "VSDIOC"    }, /* VSDIO Control */
	{ CPCAP_REG_VPLLC    , "VPLLC"     }, /* VPLL Control */
	{ CPCAP_REG_VRF1C    , "VRF1C"     }, /* VRF1 Control */
	{ CPCAP_REG_VRF2C    , "VRF2C"     }, /* VRF2 Control */
	{ CPCAP_REG_VRFREFC  , "VRFREFC"   }, /* VRFREF Control */
	{ CPCAP_REG_VWLAN1C  , "VWLAN1C"   }, /* VWLAN1 Control */
	{ CPCAP_REG_VWLAN2C  , "VWLAN2C"   }, /* VWLAN2 Control */
	{ CPCAP_REG_VSIMC    , "VSIMC"     }, /* VSIM Control */
	{ CPCAP_REG_VVIBC    , "VVIBC"     }, /* VVIB Control */
	{ CPCAP_REG_VUSBC    , "VUSBC"     }, /* VUSB Control */
	{ CPCAP_REG_VUSBINT1C, "VUSBINT1C" }, /* VUSBINT1 Control */
	{ CPCAP_REG_VUSBINT2C, "VUSBINT2C" }, /* VUSBINT2 Control */
	{ CPCAP_REG_URT      , "URT"       }, /* Useroff Regulator Trigger */
	{ CPCAP_REG_URM1     , "URM1"      }, /* Useroff Regulator Mask 1 */
	{ CPCAP_REG_URM2     , "URM2"      }, /* Useroff Regulator Mask 2 */
	{ CPCAP_REG_VAUDIOC  , "VAUDIOC"   }, /* VAUDIO Control */
	{ CPCAP_REG_CC       , "CC"        }, /* Codec Control */
	{ CPCAP_REG_CDI      , "CDI"       }, /* Codec Digital Interface */
	{ CPCAP_REG_SDAC     , "SDAC"      }, /* Stereo DAC */
	{ CPCAP_REG_SDACDI   , "SDACDI"    }, /* Stereo DAC Digital Interface */
	{ CPCAP_REG_TXI      , "TXI"       }, /* TX Inputs */
	{ CPCAP_REG_TXMP     , "TXMP"      }, /* TX MIC PGA's */
	{ CPCAP_REG_RXOA     , "RXOA"      }, /* RX Output Amplifiers */
	{ CPCAP_REG_RXVC     , "RXVC"      }, /* RX Volume Control */
	{ CPCAP_REG_RXCOA    , "RXCOA"     }, /* RX Codec to Output Amps */
	{ CPCAP_REG_RXSDOA   , "RXSDOA"    }, /* RX Stereo DAC to Output Amps */
	{ CPCAP_REG_RXEPOA   , "RXEPOA"    }, /* RX External PGA to Output Amps */
	{ CPCAP_REG_RXLL     , "RXLL"      }, /* RX Low Latency */
	{ CPCAP_REG_A2LA     , "A2LA"      }, /* A2 Loudspeaker Amplifier */
	{ CPCAP_REG_MIPIS1   , "MIPIS1"    }, /* MIPI Slimbus 1 */
	{ CPCAP_REG_MIPIS2   , "MIPIS2"    }, /* MIPI Slimbus 2 */
	{ CPCAP_REG_MIPIS3   , "MIPIS3"    }, /* MIPI Slimbus 3. */
	{ CPCAP_REG_LVAB     , "LVAB"      }, /* LMR Volume and A4 Balanced. */
	{ CPCAP_REG_CCC1     , "CCC1"      }, /* Coulomb Counter Control 1 */
	{ CPCAP_REG_CRM      , "CRM"       }, /* Charger and Reverse Mode */
	{ CPCAP_REG_CCCC2    , "CCCC2"     }, /* Coincell and Coulomb Ctr Ctrl 2 */
	{ CPCAP_REG_CCS1     , "CCS1"      }, /* Coulomb Counter Sample 1 */
	{ CPCAP_REG_CCS2     , "CCS2"      }, /* Coulomb Counter Sample 2 */
	{ CPCAP_REG_CCA1     , "CCA1"      }, /* Coulomb Counter Accumulator 1 */
	{ CPCAP_REG_CCA2     , "CCA2"      }, /* Coulomb Counter Accumulator 2 */
	{ CPCAP_REG_CCM      , "CCM"       }, /* Coulomb Counter Mode */
	{ CPCAP_REG_CCO      , "CCO"       }, /* Coulomb Counter Offset */
	{ CPCAP_REG_CCI      , "CCI"       }, /* Coulomb Counter Integrator */
	{ CPCAP_REG_ADCC1    , "ADCC1"     }, /* A/D Converter Configuration 1 */
	{ CPCAP_REG_ADCC2    , "ADCC2"     }, /* A/D Converter Configuration 2 */
	{ CPCAP_REG_ADCD0    , "ADCD0"     }, /* A/D Converter Data 0 */
	{ CPCAP_REG_ADCD1    , "ADCD1"     }, /* A/D Converter Data 1 */
	{ CPCAP_REG_ADCD2    , "ADCD2"     }, /* A/D Converter Data 2 */
	{ CPCAP_REG_ADCD3    , "ADCD3"     }, /* A/D Converter Data 3 */
	{ CPCAP_REG_ADCD4    , "ADCD4"     }, /* A/D Converter Data 4 */
	{ CPCAP_REG_ADCD5    , "ADCD5"     }, /* A/D Converter Data 5 */
	{ CPCAP_REG_ADCD6    , "ADCD6"     }, /* A/D Converter Data 6 */
	{ CPCAP_REG_ADCD7    , "ADCD7"     }, /* A/D Converter Data 7 */
	{ CPCAP_REG_ADCAL1   , "ADCAL1"    }, /* A/D Converter Calibration 1 */
	{ CPCAP_REG_ADCAL2   , "ADCAL2"    }, /* A/D Converter Calibration 2 */
	{ CPCAP_REG_USBC1    , "USBC1"     }, /* USB Control 1 */
	{ CPCAP_REG_USBC2    , "USBC2"     }, /* USB Control 2 */
	{ CPCAP_REG_USBC3    , "USBC3"     }, /* USB Control 3 */
	{ CPCAP_REG_UVIDL    , "UVIDL"     }, /* ULPI Vendor ID Low */
	{ CPCAP_REG_UVIDH    , "UVIDH"     }, /* ULPI Vendor ID High */
	{ CPCAP_REG_UPIDL    , "UPIDL"     }, /* ULPI Product ID Low */
	{ CPCAP_REG_UPIDH    , "UPIDH"     }, /* ULPI Product ID High */
	{ CPCAP_REG_UFC1     , "UFC1"      }, /* ULPI Function Control 1 */
	{ CPCAP_REG_UFC2     , "UFC2"      }, /* ULPI Function Control 2 */
	{ CPCAP_REG_UFC3     , "UFC3"      }, /* ULPI Function Control 3 */
	{ CPCAP_REG_UIC1     , "UIC1"      }, /* ULPI Interface Control 1 */
	{ CPCAP_REG_UIC2     , "UIC2"      }, /* ULPI Interface Control 2 */
	{ CPCAP_REG_UIC3     , "UIC3"      }, /* ULPI Interface Control 3 */
	{ CPCAP_REG_USBOTG1  , "USBOTG1"   }, /* USB OTG Control 1 */
	{ CPCAP_REG_USBOTG2  , "USBOTG2"   }, /* USB OTG Control 2 */
	{ CPCAP_REG_USBOTG3  , "USBOTG3"   }, /* USB OTG Control 3 */
	{ CPCAP_REG_UIER1    , "UIER1"     }, /* USB Interrupt Enable Rising 1 */
	{ CPCAP_REG_UIER2    , "UIER2"     }, /* USB Interrupt Enable Rising 2 */
	{ CPCAP_REG_UIER3    , "UIER3"     }, /* USB Interrupt Enable Rising 3 */
	{ CPCAP_REG_UIEF1    , "UIEF1"     }, /* USB Interrupt Enable Falling 1 */
	{ CPCAP_REG_UIEF2    , "UIEF2"     }, /* USB Interrupt Enable Falling 1 */
	{ CPCAP_REG_UIEF3    , "UIEF3"     }, /* USB Interrupt Enable Falling 1 */
	{ CPCAP_REG_UIS      , "UIS"       }, /* USB Interrupt Status */
	{ CPCAP_REG_UIL      , "UIL"       }, /* USB Interrupt Latch */
	{ CPCAP_REG_USBD     , "USBD"      }, /* USB Debug */
	{ CPCAP_REG_SCR1     , "SCR1"      }, /* Scratch 1 */
	{ CPCAP_REG_SCR2     , "SCR2"      }, /* Scratch 2 */
	{ CPCAP_REG_SCR3     , "SCR3"      }, /* Scratch 3 */
	{ CPCAP_REG_VMC      , "VMC"       }, /* Video Mux Control */
	{ CPCAP_REG_OWDC     , "OWDC"      }, /* One Wire Device Control */
	{ CPCAP_REG_GPIO0    , "GPIO0"     }, /* GPIO 0 Control */
	{ CPCAP_REG_GPIO1    , "GPIO1"     }, /* GPIO 1 Control */
	{ CPCAP_REG_GPIO2    , "GPIO2"     }, /* GPIO 2 Control */
	{ CPCAP_REG_GPIO3    , "GPIO3"     }, /* GPIO 3 Control */
	{ CPCAP_REG_GPIO4    , "GPIO4"     }, /* GPIO 4 Control */
	{ CPCAP_REG_GPIO5    , "GPIO5"     }, /* GPIO 5 Control */
	{ CPCAP_REG_GPIO6    , "GPIO6"     }, /* GPIO 6 Control */
	{ CPCAP_REG_MDLC     , "MDLC"      }, /* Main Display Lighting Control */
	{ CPCAP_REG_KLC      , "KLC"       }, /* Keypad Lighting Control */
	{ CPCAP_REG_ADLC     , "ADLC"      }, /* Aux Display Lighting Control */
	{ CPCAP_REG_REDC     , "REDC"      }, /* Red Triode Control */
	{ CPCAP_REG_GREENC   , "GREENC"    }, /* Green Triode Control */
	{ CPCAP_REG_BLUEC    , "BLUEC"     }, /* Blue Triode Control */
	{ CPCAP_REG_CFC      , "CFC"       }, /* Camera Flash Control */
	{ CPCAP_REG_ABC      , "ABC"       }, /* Adaptive Boost Control */
	{ CPCAP_REG_BLEDC    , "BLEDC"     }, /* Bluetooth LED Control */
	{ CPCAP_REG_CLEDC    , "CLEDC"     }, /* Camera Privacy LED Control */
	{ CPCAP_REG_OW1C     , "OW1C"      }, /* One Wire 1 Command */
	{ CPCAP_REG_OW1D     , "OW1D"      }, /* One Wire 1 Data */
	{ CPCAP_REG_OW1I     , "OW1I"      }, /* One Wire 1 Interrupt */
	{ CPCAP_REG_OW1IE    , "OW1IE"     }, /* One Wire 1 Interrupt Enable */
	{ CPCAP_REG_OW1      , "OW1"       }, /* One Wire 1 Control */
	{ CPCAP_REG_OW2C     , "OW2C"      }, /* One Wire 2 Command */
	{ CPCAP_REG_OW2D     , "OW2D"      }, /* One Wire 2 Data */
	{ CPCAP_REG_OW2I     , "OW2I"      }, /* One Wire 2 Interrupt */
	{ CPCAP_REG_OW2IE    , "OW2IE"     }, /* One Wire 2 Interrupt Enable */
	{ CPCAP_REG_OW2      , "OW2"       }, /* One Wire 2 Control */
	{ CPCAP_REG_OW3C     , "OW3C"      }, /* One Wire 3 Command */
	{ CPCAP_REG_OW3D     , "OW3D"      }, /* One Wire 3 Data */
	{ CPCAP_REG_OW3I     , "OW3I"      }, /* One Wire 3 Interrupt */
	{ CPCAP_REG_OW3IE    , "OW3IE"     }, /* One Wire 3 Interrupt Enable */
	{ CPCAP_REG_OW3      , "OW3"       }, /* One Wire 3 Control */
	{ CPCAP_REG_GCAIC    , "GCAIC"     }, /* GCAI Clock Control */
	{ CPCAP_REG_GCAIM    , "GCAIM"     }, /* GCAI GPIO Mode */
	{ CPCAP_REG_LGDIR    , "LGDIR"     }, /* LMR GCAI GPIO Direction */
	{ CPCAP_REG_LGPU     , "LGPU"      }, /* LMR GCAI GPIO Pull-up */
	{ CPCAP_REG_LGPIN    , "LGPIN"     }, /* LMR GCAI GPIO Pin */
	{ CPCAP_REG_LGMASK   , "LGMASK"    }, /* LMR GCAI GPIO Mask */
	{ CPCAP_REG_LDEB     , "LDEB"      }, /* LMR Debounce Settings */
	{ CPCAP_REG_LGDET    , "LGDET"     }, /* LMR GCAI Detach Detect */
	{ CPCAP_REG_LMISC    , "LMISC"     }, /* LMR Misc Bits */
	{ CPCAP_REG_LMACE    , "LMACE"     }, /* LMR Mace IC Support */
	{ -1, "" },
	{}
};

const char* capcap_regname(short reg) {
	const struct regname * r = regnames;
	while (r && r->reg < CPCAP_REG_LMACE) {
		if (r->reg == reg)
			return r->name;
		r++;
	}
	return "";
}
EXPORT_SYMBOL(capcap_regname);

void capcap_dumpnames(void) {
	const struct regname * r = regnames;
	while (r && r->reg != -1) {
		printk(KERN_DEBUG "0x%x(%d) CPCAP_REG_%s\n", r->reg, r->reg, r->name);
		r++;
	}
}
EXPORT_SYMBOL(capcap_dumpnames);
