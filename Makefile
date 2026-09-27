# SPDX-License-Identifier: GPL-2.0-or-later
#
# Convenience targets for building outside DKMS. DKMS itself only uses
# src/Kbuild, through the MAKE command in dkms.conf.

KVER ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KVER)/build
VERSION := $(shell sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)

all: modules

modules clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR)/src VERSION=$(VERSION) $@

# Needs a built module; the database is written to src/
compile_commands.json: modules
	$(MAKE) -C $(KDIR) M=$(CURDIR)/src $@

.PHONY: all modules clean compile_commands.json
