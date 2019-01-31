ifneq ($(lastword a b),b) #should be the same as $(lastword b), selects and stores the last word in the list
$(error This Makefile require make 3.81 or newer)
endif

# Set TOP to be the path to get from the current directory (where make was
# invoked) to the top of the tree. $(lastword $(MAKEFILE_LIST)) returns
# the name of this makefile relative to where make was invoked.

THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST)) #names the makefile after the last word in the list
TOP := $(patsubst %/tools/top.mk,%,$(THIS_MAKEFILE)) #sets top with a path substitution 

TOP := $(shell realpath $(TOP)) #sets top with the inherent system path to the home directory

$(info Top directory is $(TOP)) #variable used to spit out the path

CURRENT_PATH := $(shell realpath --relative-to=$(TOP) `pwd`) #gets the current workding directory relative to the top path variable
$(info Path from top is $(CURRENT_PATH)) #grabs the path from the "top" directory
