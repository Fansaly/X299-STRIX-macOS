# Makefile

DOWNLOADS_DIR = ./Downloads
D_KEXTS_DIR = $(DOWNLOADS_DIR)/Kexts
D_TOOLS_DIR = $(DOWNLOADS_DIR)/Tools
L_KEXTS_DIR = ./Kexts
L_TOOLS_DIR = ./Tools
UTILS_DIR = $(L_TOOLS_DIR)/Utils
WEBDRIVER_DIR=$(DOWNLOADS_DIR)/WebDriver

HOTPATCH = ./Hotpatch
D_HOTPATCH = ./Hotpatch/Downloads

BUILD_DIR = ./Build
BACKUP_DIR = ./Backup
CONFIG_DIR = ./Config
CONFIG_PLIST = $(CONFIG_DIR)/config.plist
UPDATES_PLIST = /tmp/kexts.updates.STRIX.plist

IASL_OPTS = -vs -ve
IASL_ZIP = $(shell find $(D_TOOLS_DIR) -type f -name iasl.zip)
IASL = $(shell find $(D_TOOLS_DIR) -type f -perm -u+x -name iasl)
AML = $(BUILD_DIR)/SSDT-STRIX.aml


# Build DSDT/SSDT patches
$(BUILD_DIR)/%.aml: $(HOTPATCH)/%.dsl
	@ $(IASL) $(IASL_OPTS) -p $@ $<

.PHONY: build
build: clean $(AML)

.PHONY: clean
clean:
	@ rm -f $(BUILD_DIR)/*.aml


# Download Tools/Kexts/Hotpatch
.PHONY: download
download:
	@ echo "\\033[38;5;128;48;5;248m Downloading Tools ... \\033[0m"
	@ make download-tools
	@ echo "\n\\033[38;5;128;48;5;248m Downloading Kexts ... \\033[0m"
	@ make download-kexts
	@ echo "\n\\033[38;5;128;48;5;248m Downloading Hotpatch ... \\033[0m"
	@ make download-hotpatch

.PHONY: download-tools
download-tools:
	@ $(L_TOOLS_DIR)/download.sh -c "$(CONFIG_PLIST)" -d "$(D_TOOLS_DIR)" -t "Tools"

.PHONY: download-kexts
download-kexts:
	@ $(L_TOOLS_DIR)/download.sh -c "$(CONFIG_PLIST)" -d "$(D_KEXTS_DIR)" -t "Kexts"

.PHONY: download-hotpatch
download-hotpatch:
	@ $(L_TOOLS_DIR)/download.sh -c "$(CONFIG_PLIST)" -d "$(D_HOTPATCH)" -t "Hotpatch"


# Install AML/Kexts
.PHONY: install
install:
	@ echo "\\033[38;5;52;48;5;248m Installing AML: \\033[0m"
	@ make install-aml
	@ echo "\n\\033[38;5;128;48;5;248m Installing Kexts: \\033[0m"
	@ make install-kexts

.PHONY: install-aml
install-aml: $(AML)
	$(eval EFI_DIR := $(shell make mount))
	rm -f $(EFI_DIR)/EFI/CLOVER/ACPI/patched/*.aml
	cp $(AML) $(EFI_DIR)/EFI/CLOVER/ACPI/patched

.PHONY: install-kexts
install-kexts:
	@ make set-tsc
	$(eval EFI_DIR := $(shell make mount))
	@ $(L_TOOLS_DIR)/install.sh -c "$(CONFIG_PLIST)" -k "$(EFI_DIR)/EFI/CLOVER/kexts/Other" -d "$(D_KEXTS_DIR)" -l "$(L_KEXTS_DIR)"

# Set TSCAdjustReset CPU threads
.PHONY: set-tsc
set-tsc:
	@ $(L_TOOLS_DIR)/set_tsc.sh -k "$(L_KEXTS_DIR)/TSCAdjustReset.kext"


# Check kexts updates
.PHONY: update-kexts
update-kexts:
	@ $(L_TOOLS_DIR)/update_kexts.sh -c "$(CONFIG_PLIST)" -d "$(D_KEXTS_DIR)" -o "$(UPDATES_PLIST)"

# Upgrade kexts
.PHONY: upgrade-kexts
upgrade-kexts:
	$(eval EFI_DIR := $(shell make mount))
	@ $(L_TOOLS_DIR)/upgrade_kexts.sh -c "$(UPDATES_PLIST)" -k "$(EFI_DIR)/EFI/CLOVER/kexts/Other" -d "$(D_KEXTS_DIR)"


# Unarchive
.PHONY: unarchive
unarchive:
	@ $(UTILS_DIR)/unarchive.sh -d "$(DOWNLOADS_DIR)"


# NVIDIA Web Driver
.PHONY: list-WebDriver
list-WebDriver:
	@ # How to pass argument to Makefile from command line
	@ # Learn more: https://stackoverflow.com/questions/6273608
	@ total=$(firstword $(filter-out $@,$(MAKECMDGOALS))); \
	if [[ ! "$$total" =~ ^[0-9]+$$ ]]; then total=1; fi; \
	$(L_TOOLS_DIR)/web_driver.sh -n $$total

.PHONY: download-WebDriver
download-WebDriver:
	@ $(L_TOOLS_DIR)/web_driver.sh -o "$(WEBDRIVER_DIR)"


# Backup CLOVER
.PHONY: backup
backup:
	$(eval EFI_DIR := $(shell make mount))
	@ $(L_TOOLS_DIR)/backup_clover.sh -d "$(EFI_DIR)" -o "$(BACKUP_DIR)"


# Mount EFI partition
.PHONY: mount
mount:
	@ $(UTILS_DIR)/mount_efi.sh


# Update this repo.
.PHONY: update-repo
update-repo:
	@ git pull --rebase --stat origin master


# Do nothing when get a job that doesn't
# match, rather than throw an error
%:
	@:
