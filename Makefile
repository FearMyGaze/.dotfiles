.PHONY: help save deploy clean check-stow init setup list brew-save brew-install

SHELL := /bin/bash

check-stow:
	@which stow >/dev/null 2>&1 || (echo "Stow not installed. Run: brew install stow (macOS) or apt install stow (Linux)" && exit 1)

check-brew:
	@which brew >/dev/null 2>&1 || (echo "Homebrew not installed" && exit 1)

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

brew-save: check-brew
	@CURRENT_OS=$$(uname -s | sed 's/Darwin/macos/;s/Linux/linux/'); \
	mkdir -p "$$CURRENT_OS/brew"; \
	brew bundle dump --force --file="$$CURRENT_OS/brew/Brewfile"; \
	echo "Saved Homebrew packages to $$CURRENT_OS/brew/Brewfile"

brew-install: check-brew
	@CURRENT_OS=$$(uname -s | sed 's/Darwin/macos/;s/Linux/linux/'); \
	if [ -f "$$CURRENT_OS/brew/Brewfile" ]; then \
		brew bundle install --file="$$CURRENT_OS/brew/Brewfile"; \
	else \
		echo "No Brewfile found in $$CURRENT_OS/brew/"; \
	fi

list:
	@echo "Available packages:"
	@ls -d */ 2>/dev/null | sed 's#/##'

clean:
	@find ~ -maxdepth 1 -type l -lname "*$(shell basename $(CURDIR))*" -delete 2>/dev/null || true
	@echo "Removed stow symlinks"

help:
	@echo "Dotfiles with GNU Stow"
	@echo "======================"
	@echo "make save         - Save current machine dotfiles to repo"
	@echo "make deploy       - Symlink current OS dotfiles to home"
	@echo "make brew-save    - Save Homebrew packages to Brewfile"
	@echo "make brew-install - Install Homebrew packages from Brewfile"
	@echo "make list         - Show available packages"
	@echo "make clean        - Remove stow symlinks"