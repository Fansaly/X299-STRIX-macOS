# Makefile

BACKUPDIR=./Backup
CONFIGDIR=./Config
CONFIGPLIST=$(CONFIGDIR)/config.plist
DOWNLOADSDIR=./Downloads
D_KEXTSDIR=$(DOWNLOADSDIR)/Kexts
D_TOOLSDIR=$(DOWNLOADSDIR)/Tools
L_KEXTSDIR=./Kexts
L_TOOLSDIR=./Tools

BUILDDIR=./Build
HOTPATCH=./Hotpatch
D_HOTPATCH=./Hotpatch/Downloads
AML=$(BUILDDIR)/SSDT-STRIX.aml

IASLOPTS=-vs -ve
IASLZIP=$(shell find $(D_TOOLSDIR) -type f -name iasl.zip)
IASL=$(shell find $(D_TOOLSDIR) -type f -perm -u+x -name iasl)


# Build DSDT/SSDT patches
$(BUILDDIR)/%.aml: $(HOTPATCH)/%.dsl
	$(IASL) $(IASLOPTS) -p $@ $<

.PHONY: build
build: clean $(AML)

.PHONY: clean
clean:
	@ rm -f $(BUILDDIR)/*.aml


# Download Tools/Kexts/Hotpatch
.PHONY: download
download: download-tools download-kexts download-hotpatch

.PHONY: download-tools
download-tools:
	$(L_TOOLSDIR)/download.sh -c "$(CONFIGPLIST)" -d "$(D_TOOLSDIR)" -t "Tools"

.PHONY: download-kexts
download-kexts:
	$(L_TOOLSDIR)/download.sh -c "$(CONFIGPLIST)" -d "$(D_KEXTSDIR)" -t "Kexts"

.PHONY: download-hotpatch
download-hotpatch:
	$(L_TOOLSDIR)/download.sh -c "$(CONFIGPLIST)" -d "$(D_HOTPATCH)" -t "Hotpatch"


# unarchive
.PHONY: unarchive
unarchive:
	$(L_TOOLSDIR)/unarchive.sh -d "$(DOWNLOADSDIR)"


# mount EFI partition
.PHONY: mount
mount:
	@ $(L_TOOLSDIR)/mount_efi.sh


# Install AML/Kexts
.PHONY: install
install: install-aml install-kexts

.PHONY: install-aml
install-aml: $(AML)
	$(eval EFIDIR:=$(shell make mount))
	rm -f $(EFIDIR)/EFI/CLOVER/ACPI/patched/*.aml
	cp $(AML) $(EFIDIR)/EFI/CLOVER/ACPI/patched

adjust-TSCAdjustReset:
	$(L_TOOLSDIR)/TSCAdjustReset.sh -k "$(L_KEXTSDIR)/TSCAdjustReset.kext"

.PHONY: install-kexts
install-kexts:
	@ make adjust-TSCAdjustReset && echo
	$(eval EFIDIR:=$(shell make mount))
	@ $(L_TOOLSDIR)/install.sh -c "$(CONFIGPLIST)" -k "$(EFIDIR)/EFI/CLOVER/kexts/Other" -d "$(D_KEXTSDIR)" -l "$(L_KEXTSDIR)"


# Check update for download kexts
.PHONY: check-kexts
check-kexts:
	@ $(L_TOOLSDIR)/check_kexts.sh -c "$(CONFIGPLIST)" -d "$(D_KEXTSDIR)"


# update this pro.
.PHONY: update
update:
	git pull --rebase --stat origin master

# Backup EFI/CLOVER
.PHONY: backup
backup:
	$(eval EFIDIR:=$(shell make mount))
	$(L_TOOLSDIR)/backup_clover.sh -d "$(EFIDIR)/EFI" -o "$(BACKUPDIR)"
