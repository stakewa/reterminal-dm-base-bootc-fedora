#
# Copyright (C) 2026 Daaf Wassenaar <contact@daaf.dev>
# License: MIT
#

ifndef KERNEL_VERSION
$(error KERNEL_VERSION is not set)
endif

KERNEL_BUILD_DIR := /usr/lib/modules/$(KERNEL_VERSION)/build

obj-m += raspberrypi-gpiomem.o

all:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M=$(CURDIR) modules

install:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M=$(CURDIR) modules_install

clean:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M=$(CURDIR) clean