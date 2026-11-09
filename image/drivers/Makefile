#
# Copyright (C) 2026 Daaf Wassenaar <contact@daaf.dev>
# License: MIT
#

ifndef KERNEL_VERSION
$(error KERNEL_VERSION is not set)
endif

DRIVERS := ili9881d raspberrypi/gpiomem

.PHONY: all install clean

all install clean:
	@for driver in $(DRIVERS); do \
		$(MAKE) -C "$$driver" "$@" KERNEL_VERSION="$(KERNEL_VERSION)"; \
	done
