;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(setq-default indent-tabs-mode t) ;;Force use of Tab instead of spaces
(setq-default tab-width 4) ;;Tab equals to 4 spaces
;; Ensures that the tab-width reset to 4
(add-hook 'after-change-major-mode-hook
		  (lambda()
			(setq tab-width 4)))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Giwrgis"
	  user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:

(setq doom-font (font-spec :family "Maple Mono NF" :size 11 :weight 'light)
	  doom-variable-pitch-font (font-spec :family "Maple Mono NF" :size 11))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(setq doom-gruvbox-dark-variant "soft")
(setq doom-theme 'doom-gruvbox)
(setq doom-neotree-gruvbox-style t)
(custom-set-faces!
  '(line-number :foreground "#7c6f64")
  '(line-number-current-line :foreground "#fabd2f"))

(setq doom-themes-enable-italic t
	  doom-themes-enable-bold t)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq evil-normal-state-tag  " Normal "
	  evil-insert-state-tag  " Insert "
	  evil-visual-state-tag  " Visual "
	  evil-replace-state-tag " Replace "
	  evil-motion-state-tag  " Motion ")

(after! doom-modeline
  (setq doom-modeline-modal t
		doom-modeline-modal-icon nil))

(setq whitespace-style '(face
						 tabs
						 spaces
						 trailing
						 space-before-tab
						 space-after-tab
						 newline
						 intentation
						 empty
						 space-mark
						 tab-mark))

;;Change the characters showing
(setq whitespace-display-mappings
	  '((space-mark 32 [183] [46])
		(tab-mark 9 [8594 9] [92 9])))

;;Add custom color
(custom-set-faces!
  '(whitespace-space       :foreground "#504945")
  '(whitespace-tab         :foreground "#d65d0e" :background nil)
  '(whitespace-indentation :foreground "#504945"))

(add-hook 'prog-mode-hook #'whitespace-mode)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; source: https://nayak.io/posts/golang-development-doom-emacs/
;; golang formatting set up
;; use gofumpt
(after! lsp-mode (setq  lsp-go-use-gofumpt t))
;; automatically organize imports
(add-hook 'go-mode-hook #'lsp-deferred)
;; Make sure you don't have other goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; enable all analyzers; not done by default
(after! lsp-mode
  (setq  lsp-go-analyses '((fieldalignment . t)
						   (nilness . t)
						   (shadow . t)
						   (unusedparams . t)
						   (unusedwrite . t)
						   (useany . t)
						   (unusedvariable . t)))
  )
;; Enable pbcopy for macOS clipboard integration
(when (and (eq system-type 'darwin) (executable-find "pbcopy"))
  ;; Use pbcopy for copying
  (defun my/copy-to-clipboard (text &optional push)
	(let ((process-connection-type nil))
	  (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
		(process-send-string proc text)
		(process-send-eof proc))))

  ;; Use pbpaste for pasting
  (defun my/paste-from-clipboard ()
	(shell-command-to-string "pbpaste"))

  (setq interprogram-cut-function 'my/copy-to-clipboard)
  (setq interprogram-paste-function 'my/paste-from-clipboard))

;;Configuration of the treemacs
(map! :n "C-b" #'treemacs-select-window) ;;Keybind to switch the treemacs window
(add-hook 'window-setup-hook #'treemacs)
(add-hook 'window-setup-hook (lambda () (treemacs) (other-window 1))) ;;Switches to the next window
(setq treemacs-width 30) ;; sets the width of the window
(after! treemacs
  (setq treemacs-no-png-images t) ;;show Text/Icon instead of image
  (setq treemacs-project-follow-mode t) ;;Auto switch to the current project
  (setq treemacs-follow-mode t) ;; Auto focus to the current file
  (setq treemacs-recenter-distance 0.1) ;; Remove projects from the workspace when they are not vissible
  )

