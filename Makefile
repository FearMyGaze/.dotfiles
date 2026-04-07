.PHONY: help save deploy clean check-stow init setup list

SHELL := /bin/bash

check-stow:
	@which stow >/dev/null 2>&1 || (echo "Stow not installed. Run: brew install stow (macOS) or apt install stow (Linux)" && exit 1)

init:
	@mkdir -p macos linux common
	@echo "Created: macos/ linux/ common/"

setup: init check-stow
	@echo "Setup complete. Run 'make save' to import dotfiles or 'make deploy' to symlink them."

deploy: check-stow
	@CURRENT_OS=$$(uname -s | sed 's/Darwin/macos/;s/Linux/linux/'); \
	echo "Deploying $$CURRENT_OS dotfiles..."; \
	if [ -d "$$CURRENT_OS" ]; then \
		stow --adopt -v --ignore='docker\\.fish' --ignore='kubectl\\.fish' --ignore='orbctl\\.fish' -t $$HOME -d . $$CURRENT_OS; \
	else \
		echo "No $$CURRENT_OS directory found. Run 'make save' first."; \
	fi

save: check-stow
	@./save-dotfiles.sh

list:
	@echo "Available packages:"
	@ls -d */ 2>/dev/null | sed 's#/##'

clean:
	@find ~ -maxdepth 1 -type l -lname "*$(shell basename $(CURDIR))*" -delete 2>/dev/null || true
	@echo "Removed stow symlinks"

help:
	@echo "Dotfiles with GNU Stow"
	@echo "======================"
	@echo "make save   - Save current machine dotfiles to repo"
	@echo "make deploy - Symlink current OS dotfiles to home"
	@echo "make list   - Show available packages"
	@echo "make clean  - Remove stow symlinks"