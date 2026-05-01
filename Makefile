.PHONY: help save deploy clean check-stow init brew-save brew-install list

SHELL := /bin/bash
OS_DIR := $(shell . ./detect-os.sh >/dev/null 2>&1 && detect_os_dir)

CONFIGS := .gitconfig .config/fish .config/starship.toml .config/doom .config/ghostty .config/yazi .config/zed
BREW_FILE := $(OS_DIR)/brew/Brewfile

check-stow:
	@which stow >/dev/null 2>&1 || (echo "Stow not installed" && exit 1)

check-brew:
	@which brew >/dev/null 2>&1 || (echo "Homebrew not installed" && exit 1)

init:
	@mkdir -p macos linux-* $(OS_DIR)/brew

deploy: check-stow
	@[ -d "$(OS_DIR)" ] && stow --adopt -v -t $$HOME -d . $(OS_DIR) || (echo "No $(OS_DIR) dir. Run 'make save' first." && exit 1)

save: check-stow
	@mkdir -p $(OS_DIR) $(CONFIGS:%.%=/%)
	@for f in $(CONFIGS); do \
		src="$(HOME)/$$f"; \
		dst="$(OS_DIR)/$$f"; \
		[ "$$f" = ".gitconfig" ] && [ -f "$$src" ] && cp "$$src" "$$dst"; \
		[ -d "$$src" ] && mkdir -p "$$dst" && cp -r "$$src"/* "$$dst"/; \
	done
	@echo "Saved to $(OS_DIR)! Run 'make deploy'"

brew-save: check-brew
	@mkdir -p $(OS_DIR)/brew
	@brew bundle dump --force --file="$(BREW_FILE)"

brew-install: check-brew
	@[ -f "$(BREW_FILE)" ] && brew bundle install --file="$(BREW_FILE)" || echo "No Brewfile"

list:
	@echo "Available:"; ls -d */

clean:
	@find ~ -maxdepth 1 -type l -lname "*$(OS_DIR)*" -delete 2>/dev/null || true

help:
	@echo "Targets: save, deploy, brew-save, brew-install, list, clean"