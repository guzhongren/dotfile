.PHONY: help list pre-config pre-install install post-install finalize all setup

SCRIPTS_DIR := scripts
SHELL := /bin/bash
.ONESHELL:

help list:            ## Show available targets
	@echo "Dotfile Setup Targets:"
	@echo ""
	@echo "  pre-config     System checks (OS, Xcode, git config, SSH keys)"
	@echo "  pre-install    Package managers (Homebrew, mise)"
	@echo "  install        Software installation (casks, CLI tools, language tools)"
	@echo "  post-install   Shell/plugin setup, symlinks, git/GPG config"
	@echo "  finalize       Verify installation, show manual steps"
	@echo ""
	@echo "  all            Full automated setup (runs all stages in order)"
	@echo "  setup          Alias for all"
	@echo ""
	@echo "  Stages are idempotent and can be re-run safely."

pre-config:
	@$(SCRIPTS_DIR)/pre-config.sh

pre-install:
	@$(SCRIPTS_DIR)/pre-install.sh

install:
	@$(SCRIPTS_DIR)/install.sh

post-install:
	@$(SCRIPTS_DIR)/post-install.sh

finalize:
	@$(SCRIPTS_DIR)/finalize.sh

all: pre-config pre-install install post-install finalize

setup: all
