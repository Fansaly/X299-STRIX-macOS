# makefile
#
# Patches/Installs/Builds ACPI hotpatch binaries
#

BUILDDIR=./Build
HOTPATCH=./Hotpatch
DOWNLOADS=./Downloads

IASLOPTS=-vw 2095 -vw 2008 -vs
IASLZIP=./$(shell find $(DOWNLOADS) -type f -name iasl.zip)
$(shell macos-tools/unarchive.sh $(IASLZIP))
IASL=./$(shell find $(DOWNLOADS) -type f -perm -u+x -name iasl)

AML=$(BUILDDIR)/SSDT-STRIX.aml

.PHONY: all
all: $(AML)

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.aml

.PHONY: install
install: $(AML)
	$(eval EFIDIR:=$(shell macos-tools/mount_efi.sh))
	rm -f $(EFIDIR)/EFI/CLOVER/ACPI/patched/*.aml
	cp $(AML) $(EFIDIR)/EFI/CLOVER/ACPI/patched

$(BUILDDIR)/%.aml : $(HOTPATCH)/%.dsl
	$(IASL) $(IASLOPTS) -p $@ $<

# EOF
