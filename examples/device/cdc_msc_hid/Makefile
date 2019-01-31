include ../../../tools/top.mk

# Select the board to build for. #we need to use make -C examples/device/cdc_msc_hid BOARD=metro_m0_express to initialize the $BOARD variable for this makefile
ifeq ($(BOARD),)
  $(error You must provide a BOARD parameter)
else
  ifeq ($(wildcard $(TOP)/hw/bsp/$(BOARD)/.),) #should check the list of boards to see if entered one was valid
    $(error Invalid BOARD specified)
  endif
endif

# If the build directory is not given, make it reflect the board name.
BUILD ?= build-$(BOARD)

CROSS_COMPILE = arm-none-eabi- #arm and application binary interface CC

include $(TOP)/hw/bsp/$(BOARD)/board.mk #uses board.mk of the valid board to grab dependencies

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++ 
LD = $(CROSS_COMPILE)ld #linker
OBJCOPY = $(CROSS_COMPILE)objcopy #used to copy contents of .o files to other .o files
MKDIR = mkdir
SED = sed #used for character manipulation between filetypes (like converting C to C++)
CP = cp
RM = rm

INC += -Isrc \ #directories to search through
	-I$(TOP)/hw \
	-I$(TOP)/src

CFLAGS += \
	-fsingle-precision-constant \ #forces floating point #'s to use single precision, even if inaccurate
	-fno-strict-aliasing \ #allows for pointers of multiple types to point to and change the same object
	-Wdouble-promotion \ #gives a warning when float is implicitly promoted to double
	-Wno-endif-labels \ #don't warn about trailing text after #else or #endif
	-Wstrict-prototypes \ #warn if a function is declared/definied without argument types
	-Werror-implicit-function-declaration \ #warns if a function is called without being declared
	-Wfloat-equal \ #warns if floating point values are used in equality comparisons
	-Wundef \ #warns if undefined identifier is evaluated in an #if directive; identifiers are replaced with 0
	-Wshadow \ #warns when a local variable or type shadows another
	-Wwrite-strings \ #warns when trying to write to string constants
	-Wsign-compare \ #warns when comparison between sign and unsigned could become incorrect when signed is converted to unsigned
	-Wmissing-format-attribute \ #warns when function pointers might be candidates for format attributes ???
	-Wno-deprecated-declarations \ #do not warn about depreciated declarations
	-Wnested-externs \ #warn if an extern declaration is encountered within a function ???
	-Wunreachable-code \ #warn when code is never executed
	-Wcast-align \ #warn when pointers are cast and memory boundaries become misaligned
	-Wno-error=lto-type-mismatch \ #object type mismatch??? 
	-ffunction-sections \ #generates separate elf section for each function
	-fdata-sections #default, enables geneartion of an elf section for each variable in source

#Debugging/Optimization
ifeq ($(DEBUG), 1)
  CFLAGS += -O0 -ggdb #produce debugging information for use with GDB
else
  CFLAGS += -flto -Os #force link-time optimization
endif

CFLAGS += $(INC) -Wall -Werror -std=gnu11 -nostdlib -DBOARD_$(shell echo $(BOARD) | tr a-z A-Z)

LDFLAGS += $(CFLAGS) -nostartfiles -fshort-enums -Wl,-T,$(TOP)/$(LD_FILE) -Wl,-Map=$@.map -Wl,-cref -Wl,-gc-sections -specs=nosys.specs -specs=nano.specs 
LIBS := -lgcc -lc -lm -lnosys #link libraries

EXAMPLE_SOURCE += \
	src/main.c \
	src/msc_app.c \
	src/msc_disk_ram.c \
	src/tusb_descriptors.c

SRC_C += $(addprefix $(CURRENT_PATH)/, $(EXAMPLE_SOURCE))

LIB_SOURCE += \
	hw/bsp/$(BOARD)/board_$(BOARD).c \
	src/common/tusb_fifo.c \ #mutex and fifo buffer for reading/sending information. Looks like  a partial efficiency idea was started by wrapping data around in a buffer to fill unused space
	src/device/usbd.c \ #looks like main usb driver file, but not sure. 
	src/device/usbd_auto_desc.c \ #endpoint and device set up when connected
	src/device/usbd_control.c \ #looks like more to do with controlling how data is sent
	src/class/msc/msc_device.c \ #looks like setting up data size and control systems depending on the chip used 
	src/class/cdc/cdc_device.c \ #read/write controls
	src/class/hid/hid_device.c \ #drivers for HID devices (mouse/keyboard)
	src/tusb.c \ #sets host vs device
	src/portable/$(VENDOR)/$(CHIP_FAMILY)/dcd_$(CHIP_FAMILY).c #portability options based on chip

SRC_C += $(LIB_SOURCE)

OBJ = $(addprefix $(BUILD)/obj/, $(SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/obj/, $(SRC_S:.s=.o))

all: $(BUILD)/$(BOARD)-firmware.bin

OBJ_DIRS = $(sort $(dir $(OBJ)))
$(OBJ): | $(OBJ_DIRS)
$(OBJ_DIRS):
	@$(MKDIR) -p $@

$(BUILD)/$(BOARD)-firmware.elf: $(OBJ)
	@echo LINK $@
	@$(CC) -o $@ $(LDFLAGS) $^ -Wl,--start-group $(LIBS) -Wl,--end-group

$(BUILD)/$(BOARD)-firmware.bin: $(BUILD)/$(BOARD)-firmware.elf
	@echo CREATE $@
	$(OBJCOPY) -O binary -j .vectors -j .text -j .data $^ $@

# We set vpath to point to the top of the tree so that the source files
# can be located. By following this scheme, it allows a single build rule
# to be used to compile all .c files.
vpath %.c . $(TOP)
$(BUILD)/obj/%.o: %.c
	@echo CC $@
	@$(CC) $(CFLAGS) -c -MD -o $@ $<
	@# The following fixes the dependency file.
	@# See http://make.paulandlesley.org/autodep.html for details.
	@# Regex adjusted from the above to play better with Windows paths, etc.
	@$(CP) $(@:.o=.d) $(@:.o=.P); \
	  $(SED) -e 's/#.*//' -e 's/^.*:  *//' -e 's/ *\\$$//' \
	      -e '/^$$/ d' -e 's/$$/ :/' < $(@:.o=.d) >> $(@:.o=.P); \
	  $(RM) $(@:.o=.d)

clean:
	rm -rf build-$(BOARD)
