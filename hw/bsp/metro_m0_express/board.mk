CFLAGS = \ #names of variables that are set to specify addition switches passed to compiler
	-DCFG_TUSB_MCU=OPT_MCU_SAMD21 \ #tells TinyUSB what platform is being built (SAMD21)
	-DCONF_DFLL_OVERWRITE_CALIBRATION=0 \
	-D__SAMD21G18A__ \
	-mthumb \ #requests that the compiler targets the T32 instruction set (assembly files)
	-mabi=aapcs-linux \ #designates Application Binary Interface (ABI) between the "Procedure Call for the ARM Architecture" (aapcs) and Linux. The ABI defines how data structures and computational routines are access in machine language, and here it helps Linux talk with the ARM architecture. 
	-mcpu=cortex-m0plus \ #specifies name of target ARM processor (m0 in this case)
	-msoft-float \ #disables generation of floating point instructions.
	-mfloat-abi=soft #specifies the floating point ABI to use. Soft causes GCC to generate output containing library calls for floating-point operations. I think these things used together make it so that the hardware isn't responsible for floating point operations, and it is pushed off into software to eventually be done by other hardware. 

# All source paths should be relative to the top level.
LD_FILE = hw/bsp/metro_m0_express/samd21g18a_flash.ld #location to link-editor support library

LD_FLAGS += -mthumb -mcpu=cortex-m0plus #same flags as above

SRC_C += \ #source code c files
	hw/mcu/microchip/samd/asf4/samd21/gcc/gcc/startup_samd21.c \ #includes startup handlers and definitions
	hw/mcu/microchip/samd/asf4/samd21/gcc/system_samd21.c \ #sets and starts clock
	hw/mcu/microchip/samd/asf4/samd21/hpl/gclk/hpl_gclk.c \ #not sure about this one, lots of bit-shifted clock generators?
	hw/mcu/microchip/samd/asf4/samd21/hpl/pm/hpl_pm.c \ #power management, sleep, reset
	hw/mcu/microchip/samd/asf4/samd21/hpl/sysctrl/hpl_sysctrl.c #initializesall GCLK generators

INC += \ #include directories to look for files
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/ \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/config \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/include \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/hal/include \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/hal/utils/include \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd51/hpl/pm/ \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/hpl/port \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/hri \
	-I$(TOP)/hw/mcu/microchip/samd/asf4/samd21/CMSIS/Include

VENDOR = microchip
CHIP_FAMILY = samd21
