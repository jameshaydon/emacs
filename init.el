;;; init.el --- -*- lexical-binding: t -*-

;; Better GC
(defvar better-gc-cons-threshold 67108864 ; 64mb
  "The default value to use for `gc-cons-threshold'.

If you experience freezing, decrease this.  If you experience stuttering, increase this.")

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold better-gc-cons-threshold)
            (setq file-name-handler-alist file-name-handler-alist-original)
            (makunbound 'file-name-handler-alist-original)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (if (boundp 'after-focus-change-function)
                (add-function :after after-focus-change-function
                              (lambda ()
                                (unless (frame-focus-state)
                                  (garbage-collect))))
              (add-hook 'after-focus-change-function 'garbage-collect))
            (defun gc-minibuffer-setup-hook ()
              (setq gc-cons-threshold (* better-gc-cons-threshold 2)))

            (defun gc-minibuffer-exit-hook ()
              (garbage-collect)
              (setq gc-cons-threshold better-gc-cons-threshold))

            (add-hook 'minibuffer-setup-hook #'gc-minibuffer-setup-hook)
            (add-hook 'minibuffer-exit-hook #'gc-minibuffer-exit-hook)))

;; Change default directory to ~
(cd "~")

(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'init-package)

(use-package exec-path-from-shell
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(add-to-list 'load-path "~/dev/")

;;;;;;;;;;;;;;
;; bindings ;;
;;;;;;;;;;;;;;

;; Unbind unneeded keys
(global-set-key (kbd "s-s") nil)
;;(global-set-key (kbd "C-z") nil)
(global-set-key (kbd "M-z") nil)
;;(global-set-key (kbd "C-x C-z") nil)
(global-set-key (kbd "M-/") nil)
;; Move up/down paragraph
(global-set-key (kbd "M-n") #'forward-paragraph)
(global-set-key (kbd "M-p") #'backward-paragraph)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an emacs daemon/server ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(server-start)

;;;;;;;;;;;;;;;;;;;
;; Font and text ;;
;;;;;;;;;;;;;;;;;;;

(set-face-attribute 'default nil
                    :family "IBM Plex Mono"
                    :height 132)

(setq-default line-spacing 7) ;; line-height
(setq font-lock-maximum-decoration t) ;; Always with the font-locking

;;;;;;;;;;;;;;;
;; Small fry ;;
;;;;;;;;;;;;;;;

(use-package better-defaults)

;; get rid of splash screen
(setq inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-splash-screen t
      inhibit-startup-echo-area-message t)

(transient-mark-mode 1) ; makes the region visible

(save-place-mode t) ;; save place -- move to the place I was last time I visited this file

(setq ring-bell-function 'ignore) ;; disable the annoying bell ring

(setq echo-keystrokes 0.2) ;; Show Keystrokes in Progress

(setq-default create-lockfiles nil) ;; Don't Lock Files

;; Better Compilation
(setq-default compilation-always-kill t) ; kill compilation process before starting another
(setq-default compilation-ask-about-save nil) ; save all buffers on `compile'
(setq-default compilation-scroll-output t)

;; Move Custom-Set-Variables to Different File
(setq custom-file (concat user-emacs-directory "custom-set-variables.el"))
(load custom-file 'noerror)


;; Avoid performance issues in files with very long lines.
(unless (version<= emacs-version "27")
  (global-so-long-mode 1))

(setq require-final-newline t) ;; Add a newline automatically at the end of the file upon save.

;; Enable smooth scrolling ;;

;; Vertical Scroll
(setq scroll-step 1)
(setq scroll-margin 1)
(setq scroll-conservatively 101)
(setq scroll-up-aggressively 0.01)
(setq scroll-down-aggressively 0.01)
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
;; Horizontal Scroll
(setq hscroll-step 1)
(setq hscroll-margin 1)

(delete-selection-mode 1) ;; Make typing delete/overwrites selected text

;; from https://github.com/bbatsov/prelude/
;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
;; autosave the undo-tree history
(setq undo-tree-history-directory-alist
      `((".*" . ,temporary-file-directory)))

(setq tab-always-indent 'complete) ;; smart tab behavior - indent or complete

;; bind imenu brings up a really nice menu (table-of-contents like thing) of
;; the current buffer
(global-set-key (kbd "M-i") 'imenu)

;; Warn before you exit emacs!
(setq confirm-kill-emacs 'yes-or-no-p)

;; make all "yes or no" prompts show "y or n" instead
(fset 'yes-or-no-p 'y-or-n-p)

;; (setq make-backup-files nil)
;; (setq auto-save-default nil)

;; Allows moving point to other windows by using SHIFT+<arrow key>.
(windmove-default-keybindings)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)
(diminish 'auto-revert-mode)

;; UTF8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))
(prefer-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
(set-keyboard-coding-system 'utf-8)
(setenv "LC_ALL" "en_US.UTF-8")
(setenv "LANG" "en_US.UTF-8")
(setenv "LC_CTYPE" "en_US.UTF-8")
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

(setq-default fill-column 80          ;; Let's avoid going over 80 columns
              truncate-lines nil      ;; I never want to scroll horizontally
              indent-tabs-mode nil)   ;; Use spaces instead of tabs

;; Wrap long lines when editing text
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;; Do not show the “Fill” indicator in the mode line.
(diminish 'auto-fill-function)

;; Sessions
;; (desktop-save-mode 1)

;; Make ediff diff at the character level
(setq-default ediff-forward-word-function 'forward-char)

;; By default, Emacs thinks a sentence is a full-stop followed by 2
;; spaces. Let’s make it full-stop and 1 space.
(setq sentence-end-double-space nil)

;; Let me upcase or downcase a region, which is disabled by default.
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; "after pressing C-u C-SPC to jump to a mark popped off the local mark ring, you can just keeping pressing C-SPC to repeat!"
(setq set-mark-command-repeat-pop t)

;; Save buffer after some idle time after a change.
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 5)

;;;;;;;;;;;;;;;;;;;;;
;; Theme + visuals ;;
;;;;;;;;;;;;;;;;;;;;;

;; Emacs resizes the (GUI) frame when your newly set font is larger
;; (or smaller) than the system default. This seems to add 0.4-1s to
;; startup.
(setq frame-inhibit-implied-resize t)

(use-package doom-themes
  :config
  ;; flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  ;;(load-theme 'doom-Iosvkem t)
  ;;(set-face-background 'default "black")
  ;;(load-theme 'doom-one-light t)
  ;; (load-theme 'doom-outrun-electric t)
  ;;(load-theme 'doom-acario-dark t)
  (load-theme 'doom-acario-light t)
  ;;(set-face-background 'default "white")
  )

(defun light-theme-mode ()
  "Switch to light mode."
  (interactive)
  (load-theme 'doom-acario-light t)
  ;;(set-face-background 'default "white")
  )

(defun dark-theme-mode ()
  "Switch to dark mode."
  (interactive)
  (load-theme 'doom-outrun-electric t)
  ;;(set-face-background 'default "black")
  )

(use-package doom-modeline
  :custom
  ;; Don't compact font caches during GC. Windows Laggy Issue
  (inhibit-compacting-font-caches t)
  (doom-modeline-minor-modes t)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-height 15)
  :config
  (doom-modeline-mode))

;; Line and column numbers
(if (version< emacs-version "26.1")
    (global-linum-mode)
  (global-display-line-numbers-mode t))
(column-number-mode t)

(display-time-mode 1)
(display-battery-mode 1)

;; Datetime format
(setq display-time-day-and-date t
      display-time-24hr-format t)

;; (global-hl-line-mode t) ;; highlight the current line

(blink-cursor-mode -1) ;; No blinking cursor

;; Enable visual-line-mode globally
;; NOTE: disabled since it makes swiper init quite slow.
;; (global-visual-line-mode t)
;; (diminish 'visual-line-mode)

;; prettify-symbols-mode was introduced in 24.4
(global-prettify-symbols-mode 1)
(setq prettify-symbols-unprettify-at-point 'right-edge)
(defun add-pretty-lambda ()
  "Make some word or string show as pretty Unicode symbols.  See https://unicodelookup.com for more."
  (setq prettify-symbols-alist
        '(
          ("lambda" . 955)
          ("delta" . 120517)
          ("epsilon" . 120518)
          ("->" . 8594)
          ("<=" . 8804)
          (">=" . 8805)
          ("=>" . 8658)
          )))
(add-hook 'prog-mode-hook 'add-pretty-lambda)
(add-hook 'org-mode-hook 'add-pretty-lambda)

;; Show trailing white-spaces
(setq show-trailing-whitespace t)

;; Use visual bell instead of audio
(setq visible-bell 1)

;; Enable visual line fringe and empty line indicator
(setq visual-line-fringe-indicators
      '(left-curly-arrow right-curly-arrow))
(setq-default left-fringe-width nil
              indicate-empty-lines t)

;; Unset the frame title and remove the icon
(setq frame-title-format nil)
(setq ns-use-proxy-icon nil)

;; Avoid gaps between windows when tiling, unless the currently used
;; typeface is exactly aligned with the effective display area.
;; Link: https://github.com/d12frosted/homebrew-emacs-plus/issues/130
(setq frame-resize-pixelwise t)

;; Never lose your cursor again
;; (use-package beacon
;;   :diminish
;;   :config
;;   (beacon-mode 1))

;; Temporarily disabling font-lock and switching to a barebones
;; mode-line, until you stop scrolling (at which point it re-enables).
(use-package fast-scroll
  :diminish fast-scroll-mode
  :config
  (fast-scroll-config)
  (fast-scroll-mode 1))

;;;;;;;;;;
;; crux ;;
;;;;;;;;;;

(use-package crux
  :bind
  (("C-a" . crux-move-beginning-of-line)
   ("C-x 4 t" . crux-transpose-windows)
   ("C-x K" . crux-kill-other-buffers)
   ;;("C-k" . crux-smart-kill-line)
   )
  :config
  (crux-with-region-or-buffer indent-region)
  (crux-with-region-or-buffer untabify)
  (crux-with-region-or-point-to-eol kill-ring-save)
  (defalias 'rename-file-and-buffer #'crux-rename-file-and-buffer))

;;;;;;;;;;;;;
;; Various ;;
;;;;;;;;;;;;;

;; When find-file and dired-mode try to access a non writable file
;; auto-sudoedit re-opens the file automatically using sudo in TRAMP
(use-package auto-sudoedit
  :diminish auto-sudoedit-mode
  :config
  (auto-sudoedit-mode 1))

;; MoveText allows you to move the current line using M-up / M-down
;; (or any other bindings you choose) if a region is marked, it will
;; move the region instead.
(use-package move-text
  :config
  (move-text-default-bindings))

;; (use-package discover-my-major
;;   :bind ("C-h C-m" . discover-my-major))

;;;;;;;;;;
;; Undo ;;
;;;;;;;;;;

(use-package undo-tree
  :defer t
  :diminish
  :init
  (global-undo-tree-mode)
  :config
  ;; Make C-g quit undo tree
  (define-key undo-tree-visualizer-mode-map (kbd "C-g") 'undo-tree-visualizer-quit)
  (define-key undo-tree-visualizer-mode-map (kbd "<escape> <escape> <escape>") 'undo-tree-visualizer-quit)
  :custom
  (undo-limit 800000)
  (undo-strong-limit 12000000)
  (undo-outer-limit 120000000)
  (undo-tree-visualizer-diff t)
  (undo-tree-visualizer-timestamps t))

;;;;;;;;;;;;;;;
;; which-key ;;
;;;;;;;;;;;;;;;

(use-package which-key
  :diminish
  :defer 5
  :custom
  (which-key-separator " ")
  (which-key-prefix-prefix "+")
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.2))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; sane-term terminal ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package sane-term
  :defer t
  :bind (("C-x t" . sane-term)
         ("C-x T" . sane-term-create))
  :config
  (setq sane-term-shell-command "/bin/zsh"))

(defun my-term-mode-hook ()
  (setq bidi-paragraph-direction 'left-to-right)
  (my-inhibit-global-linum-mode))

(defun my-inhibit-global-linum-mode ()
  "Counter-act `global-linum-mode'."
  (add-hook 'after-change-major-mode-hook
            (lambda ()
              (if (version< emacs-version "26.1")
                  (linum-mode 0)
                (display-line-numbers-mode 0)))
            :append :local))

(add-hook 'term-mode-hook 'my-term-mode-hook)

;;;;;;;;;;;;;;
;; flycheck ;;
;;;;;;;;;;;;;;

(use-package flycheck
  :diminish
  :defer t
  :init (global-flycheck-mode t)
  :after (flycheck-color-mode-line flycheck-pos-tip)
  :hook
  (flycheck-mode . flycheck-pos-tip-mode)
  (flycheck-mode . flycheck-color-mode-line-mode))

;; An Emacs minor-mode for Flycheck which colors the mode-line
;; according to the Flycheck state of the current buffer.
(use-package flycheck-color-mode-line
  :defer t)

;; ;; Flycheck errors display in tooltip
;; (use-package flycheck-pos-tip
;;   :defer t
;;   :config (with-eval-after-load 'flycheck (flycheck-pos-tip-mode)))

;;;;;;;;;
;; Ivy ;;
;;;;;;;;;

(use-package ivy
  :diminish
  :demand t
  :init
  (use-package amx :defer t)
  (use-package counsel
    :diminish
    :config
    (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
    (counsel-mode 1))
  (use-package swiper
    :defer t
    :config (global-set-key "\C-s" 'swiper))
  (ivy-mode 1)
  :bind (("C-s" . swiper)
         ("C-r" . swiper-isearch-backward)
         ("C-c C-r" . ivy-resume)
         ("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         (:map ivy-minibuffer-map
               ("C-r" . ivy-previous-line-or-history)
               ("M-RET" . ivy-immediate-done))
         (:map counsel-find-file-map
               ("C-~" . counsel-goto-local-home)))
  :custom
  (amx-history-length 20)
  (ivy-use-virtual-buffers t)
  (ivy-on-del-error-function nil)
  (ivy-magic-slash-non-match-action 'ivy-magic-slash-non-match-create)
  (ivy-count-format "【%d/%d】")
  (ivy-wrap t)
  (enable-recursive-minibuffers t)
  (ivy-use-selectable-prompt t)
  (ivy-initial-inputs-alist nil)
  (swiper-action-recenter t)
  (counsel-find-file-at-point t)
  (counsel-yank-pop-separator "\n────────\n")
  (counsel-grep-base-command "rg -S --no-heading --line-number --color never '%s' %s")
  :config
  (defun counsel-goto-local-home ()
    "Go to the $HOME of the local machine."
    (interactive)
    (ivy--cd "~/"))
  ;; The following makes ivy take about a third of the frame-height.
  (setq ivy-height-alist
        '((t
           lambda (_caller)
           (/ (frame-height) 3))))
  (global-set-key (kbd "<f6>") 'ivy-resume)
  (global-set-key (kbd "C-c v") 'ivy-push-view))

(use-package ivy-yasnippet
  :after (ivy yasnippet)
  :commands ivy-yasnippet--preview
  :bind ("C-c C-y" . ivy-yasnippet)
  :config (advice-add #'ivy-yasnippet--preview :override #'ignore))

(use-package flyspell
  :diminish
  :ensure-system-package (aspell . "brew install aspell || sudo apt-get install aspell")
  :config (setq ispell-programa-name "/usr/local/bin/aspell")
  :bind (:map flyspell-mode-map
              ("C-;" . nil)
              ("C-," . nil)
              ("C-." . nil))
  :hook ((prog-mode . flyspell-prog-mode)
         (text-mode . flyspell-mode)
         ((org-mode text-mode) . flyspell-mode)))

(setq ispell-dictionary "en_GB")
(global-font-lock-mode t)
(custom-set-faces '(flyspell-incorrect ((t (:inverse-video t)))))
(setq ispell-silently-savep t) ;; Save to user dictionary without asking

(use-package ivy-rich
  :after (ivy counsel)
  :init
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  (ivy-rich-mode 1))

(use-package all-the-icons-ivy
  :after (all-the-icons ivy)
  :custom (all-the-icons-ivy-file-commands '(counsel-dired-jump
                                             counsel-find-file
                                             counsel-file-jump
                                             counsel-find-library
                                             counsel-git
                                             counsel-projectile-find-dir
                                             counsel-projectile-find-file
                                             counsel-recentf))
  :config (all-the-icons-ivy-setup))

(use-package counsel-projectile
  :after (counsel projectile)
  :demand
  :init
  (setq counsel-projectile-sort-files t)
  (setq counsel-projectile-grep-initial-input '(ivy-thing-at-point))
  (counsel-projectile-mode t)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Line-based searching ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package helm-ag
;;   
;;   :bind ("C-c r g" . helm-do-ag-project-root)
;;   :init (setq helm-ag-base-command "rg --no-heading --smart-case"))

(use-package deadgrep
  :config
  (global-set-key (kbd "C-c r g") #'deadgrep))

;; (use-package color-rg
;;   :ensure t
;;   :load-path (lambda () (expand-file-name "site-elisp/color-rg" user-emacs-directory))
;;   :bind ("C-M-s" . color-rg-search-input))

;;;;;;;;;;;;;;;;;;;;;;
;; Multiple Cursors ;;
;;;;;;;;;;;;;;;;;;;;;;

(use-package multiple-cursors
  :demand t
  :init
  (require 'mc-hide-unmatched-lines-mode)
  :bind (("C-S-c C-S-c" . mc/edit-lines)
	 ("C->"         . mc/mark-next-like-this)
	 ("C-<"         . mc/mark-previous-like-this)
         ("C-x a"       . mc/mark-all-like-this)))

;;;;;;;;;;;;;;;;;
;; Completions ;;
;;;;;;;;;;;;;;;;;

(use-package company
  :diminish
  :bind
  (:map company-active-map
        ("C-d" . company-show-doc-buffer)
        ([tab] . smarter-yas-expand-next-field-complete)
        ("TAB" . smarter-yas-expand-next-field-complete)
        ;; Use C-n,p for navigation in addition to M-n,p
        ("C-n" . (lambda () (interactive) (company-complete-common-or-cycle 1)))
        ("C-p" . (lambda () (interactive) (company-complete-common-or-cycle -1))))
  :custom
  (company-minimum-prefix-length 2)
  
  ;; Search other buffers for compleition candidates
  (company-dabbrev-other-buffers t)
  (company-dabbrev-code-other-buffers t)

  ;; Show candidates according to importance, then case, then in-buffer frequency
  (company-transformers '(company-sort-by-backend-importance
                          company-sort-prefer-same-case-prefix
                          company-sort-by-occurrence))
  
  (company-tooltip-align-annotations t)

  ;; Allow (lengthy) numbers to be eligible for completion.
  (company-complete-number t)

  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (company-show-numbers t)

  (company-tooltip-limit 10)
  (company-selection-wrap-around t)

  ;; Do not downcase completions by default.
  (company-dabbrev-downcase nil)

  ;; Even if I write something with the ‘wrong’ case,
  ;; provide the ‘correct’ casing.
  (company-dabbrev-ignore-case nil)

  ;; Trigger completion immediately.
  (company-idle-delay 0.2)
  
  (company-begin-commands '(self-insert-command))
  (company-require-match 'never)
  
  ;; invert the navigation direction if the the completion popup-isearch-match
  ;; is displayed on top (happens near the bottom of windows)
  (company-tooltip-flip-when-above t)
  :config
  (global-company-mode)
  (defun smarter-yas-expand-next-field-complete ()
    "Try to `yas-expand' and `yas-next-field' at current cursor position.

If failed try to complete the common part with `company-complete-common'"
    (interactive)
    (if yas-minor-mode
        (let ((old-point (point))
              (old-tick (buffer-chars-modified-tick)))
          (yas-expand)
          (when (and (eq old-point (point))
                     (eq old-tick (buffer-chars-modified-tick)))
            (ignore-errors (yas-next-field))
            (when (and (eq old-point (point))
                       (eq old-tick (buffer-chars-modified-tick)))
              (company-complete-common))))
      (company-complete-common)))
  )

                                        ; Documentation popups for Company
(use-package company-quickhelp
  :defer t
  :init (add-hook 'global-company-mode-hook #'company-quickhelp-mode))

;;;;;;;;;;;;;;;;
;; Projectile ;;
;;;;;;;;;;;;;;;;

(use-package projectile
  :demand
  :diminish projectile-mode
  :init
  (setq projectile-require-project-root nil)
  (setq projectile-completion-system 'ivy)
  ;;(setq projectile-indexing-method 'native)
  :config
  ;;(projectile-mode) ;; counsel-projectile will do this.
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  (add-to-list 'projectile-globally-ignored-directories ".stack-work")
  )

;;;;;;;;;;;;;;;
;; Searching ;;
;;;;;;;;;;;;;;;

;; Smart jump
(use-package smart-jump
  :config (smart-jump-setup-default-registers)
  :defer t
  ;; TODO: figure out why these are sometimes bound and sometimes not:
  :bind (("M-." . smart-jump-go)
         ("M-," . smart-jump-back))
  :custom (dumb-jump-selector 'ivy)
  )

;; Visual jump
(use-package avy
  :after flyspell
  :bind (("C-;" . avy-goto-char-timer)
	 ("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2))
  :custom
  (avy-timeout-seconds 0.2)
  (avy-style 'pre)
  :config
  (setq avy-background t))

;; Visual window select
(use-package ace-window
  :bind* ("M-o" . ace-window)
  :init (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;;;;;;;;;;;;;;;;;;;;;;
;; Parens and pairs ;;
;;;;;;;;;;;;;;;;;;;;;;

(setq show-paren-delay 0.2)
(setq show-paren-style 'mixed)
(show-paren-mode 1) ;; Show matching parens

(use-package rainbow-delimiters
  :hook ((org-mode prog-mode text-mode) . rainbow-delimiters-mode))

(use-package smartparens
  :diminish smartparens-mode
  :init
  (require 'smartparens-config)
  (smartparens-global-mode 1)
  (show-smartparens-global-mode 1)
  :config
  (setq smartparens-strict-mode t)
  (show-smartparens-global-mode t)
  (add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
  (add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)

  ;; Inspired by:
  ;; - https://github.com/Fuco1/.emacs.d/blob/master/files/smartparens.el
  ;; - https://gist.github.com/pvik/8eb5755cc34da0226e3fc23a320a3c95
  
  (define-key smartparens-mode-map (kbd "C-M-f") 'sp-forward-sexp)
  (define-key smartparens-mode-map (kbd "C-M-b") 'sp-backward-sexp)

  (define-key smartparens-mode-map (kbd "C-M-u") 'sp-backward-up-sexp)
  (define-key smartparens-mode-map (kbd "C-M-d") 'sp-down-sexp)
  (define-key smartparens-mode-map (kbd "C-M-e") 'sp-up-sexp)
  (define-key smartparens-mode-map (kbd "C-M-a") 'sp-backward-down-sexp)
  
  (define-key smartparens-mode-map (kbd "C-S-d") 'sp-beginning-of-sexp)
  (define-key smartparens-mode-map (kbd "C-S-a") 'sp-end-of-sexp)

  (define-key smartparens-mode-map (kbd "C-M-t") 'sp-transpose-hybrid-sexp)

  (define-key smartparens-mode-map (kbd "C-M-n") 'sp-forward-hybrid-sexp)
  (define-key smartparens-mode-map (kbd "C-M-p") 'sp-backward-hybrid-sexp)

  (define-key smartparens-mode-map (kbd "C-M-k") 'sp-kill-sexp)
  (define-key smartparens-mode-map (kbd "C-M-w") 'sp-copy-sexp)

  ;; Unwrapping
  (define-key smartparens-mode-map (kbd "M-<delete>") 'sp-unwrap-sexp)
  ;;(define-key smartparens-mode-map (kbd "C-M-<backspace>") 'sp-backward-unwrap-sexp)

  ;; Slurping and barfing
  (define-key smartparens-mode-map (kbd "C-<right>") 'sp-slurp-hybrid-sexp)
  (define-key smartparens-mode-map (kbd "C-<left>") 'sp-forward-barf-sexp)
  (define-key smartparens-mode-map (kbd "C-M-<left>") 'sp-backward-slurp-sexp)
  (define-key smartparens-mode-map (kbd "C-M-<right>") 'sp-backward-barf-sexp)

  (define-key smartparens-mode-map (kbd "M-D") 'sp-splice-sexp)
  (define-key smartparens-mode-map (kbd "C-M-<delete>") 'sp-splice-sexp-killing-forward)
  (define-key smartparens-mode-map (kbd "C-M-<backspace>") 'sp-splice-sexp-killing-backward)
  (define-key smartparens-mode-map (kbd "C-S-<backspace>") 'sp-splice-sexp-killing-around)
  
  (define-key smartparens-mode-map (kbd "C-]") 'sp-select-next-thing-exchange)
  (define-key smartparens-mode-map (kbd "C-<left_bracket>") 'sp-select-previous-thing)
  (define-key smartparens-mode-map (kbd "C-M-]") 'sp-select-next-thing)

  (define-key smartparens-mode-map (kbd "M-F") 'sp-forward-symbol)
  (define-key smartparens-mode-map (kbd "M-B") 'sp-backward-symbol)

  (define-key smartparens-mode-map (kbd "C-\"") 'sp-change-inner)
  ;;(define-key smartparens-mode-map (kbd "M-i") 'sp-change-enclosing)

  (bind-key "C-c f" (lambda () (interactive) (sp-beginning-of-sexp 2)) smartparens-mode-map)
  (bind-key "C-c b" (lambda () (interactive) (sp-beginning-of-sexp -2)) smartparens-mode-map)

  ;; And some more:
  (define-key smartparens-mode-map (kbd "M-(") 'sp-wrap-round)
  (define-key smartparens-mode-map (kbd "M-[") 'sp-wrap-square)
  (define-key smartparens-mode-map (kbd "M-{") 'sp-wrap-curly)
  :custom
  (sp-escape-quotes-after-insert nil)
  )

;;;;;;;;;;;;;;;
;; Indenting ;;
;;;;;;;;;;;;;;;

(setq tab-width 2)
(setq js-indent-level 2)
(setq css-indent-offset 2)

(electric-indent-mode 1)

(use-package aggressive-indent
  :config
  (global-aggressive-indent-mode 1)
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
  (add-hook 'lisp-mode-hook #'aggressive-indent-mode)
  )

;; highlight-indentation-mode
(use-package highlight-indentation
  :diminish highlight-indentation-mode
  :config
  (set-face-attribute 'highlight-indentation-face nil
                      :background "gray18")
  (set-face-attribute 'highlight-indentation-current-column-face nil
                      :background "gray18"))

;; This minor mode highlights indentation levels via font-lock
(use-package highlight-indent-guides
  :init
  (setq highlight-indent-guides-method 'column)
  :diminish highlight-indent-guides-mode
  :hook
  (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-auto-odd-face-perc 2)
  (setq highlight-indent-guides-auto-even-face-perc 1)
  (setq highlight-indent-guides-auto-character-face-perc 4))

;;;;;;;;;;;;;;;
;; prescient ;;
;;;;;;;;;;;;;;;

(use-package prescient
  :demand
  :after (counsel ivy ivy-rich swiper amx)
  :init
  (setq prescient-filter-method '(literal regexp initialism fuzzy))
  :config
  (prescient-persist-mode 1))

(use-package ivy-prescient
  
  :demand
  :after (ivy counsel prescient)
  :init
  (defun ivy-prescient-non-fuzzy (str)
    (let ((prescient-filter-method '(literal regexp)))
      (ivy-prescient-re-builder str)))
  (setq ivy-prescient-retain-classic-highlighting t
        ivy-re-builders-alist '((counsel-ag . ivy-prescient-non-fuzzy)
                                (counsel-rg . ivy-prescient-non-fuzzy)
                                (counsel-pt . ivy-prescient-non-fuzzy)
                                (counsel-grep . ivy-prescient-non-fuzzy)
                                (counsel-yank-pop . ivy-prescient-non-fuzzy)
                                (swiper . ivy-prescient-non-fuzzy)
                                (swiper-isearch . ivy-prescient-non-fuzzy)
                                (swiper-all . ivy-prescient-non-fuzzy)
                                (insert-char . ivy-prescient-non-fuzzy)
                                (t . ivy-prescient-re-builder))
        ivy-prescient-sort-commands '(:not swiper swiper-isearch ivy-switch-buffer
                                           counsel-grep counsel-ag counsel-yank-pop))
  (ivy-prescient-mode 1))

(use-package company-prescient
  :after (company prescient)
  :config (company-prescient-mode t))

;;;;;;;;;;;;;;
;; Snippets ;;
;;;;;;;;;;;;;;

(use-package yasnippet
  :defer t
  :diminish yas-minor-mode
  :init (add-hook 'prog-mode-hook #'yas-minor-mode)
  :bind
  (:map yas-minor-mode-map ("C-c C-n" . yas-expand-from-trigger-key))
  (:map yas-keymap
        (("TAB" . smarter-yas-expand-next-field)
         ([(tab)] . smarter-yas-expand-next-field)))
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs '("~/dev/yasnippet-snippets/snippets" "~/snippets"))
  (yas-reload-all)
  (defun smarter-yas-expand-next-field ()
    "Try to `yas-expand' then `yas-next-field' at current cursor position."
    (interactive)
    (let ((old-point (point))
          (old-tick (buffer-chars-modified-tick)))
      (yas-expand)
      (when (and (eq old-point (point))
                 (eq old-tick (buffer-chars-modified-tick)))
        (ignore-errors (yas-next-field))))))

;;;;;;;;;;;;;;;;;;;
;; Git and Magit ;;
;;;;;;;;;;;;;;;;;;;

;; (use-package smerge-mode
;;   
;;   :defer t
;;   :config
;;   (setq smerge-command-prefix "\C-cs")
;;   )

(use-package magit
  :defer t
  :after (ivy counsel)
  :bind (("C-x g" . magit-status))
  :config
  (setq vc-handled-backends nil)
  (global-magit-file-mode)
  (setq magit-completing-read-function 'ivy-completing-read)
  ;;:init (magit-auto-revert-mode -1)
  )

(use-package git-timemachine :defer t)

(defun my/git-commit-reminder ()
  (insert "\n\n# The commit subject line ought to finish the phrase:
# “If applied, this commit will ⟪your subject line here⟫.” ")
  (beginning-of-buffer))

(add-hook 'git-commit-setup-hook 'my/git-commit-reminder)

(use-package magit-todos
  :defer t
  :after magit
  :hook (magit-mode . magit-todos-mode))

(use-package git-gutter-fringe
  
  :defer t
  :config
  (global-git-gutter-mode t)
  ;; (setq git-gutter-fr:side 'right-fringe)
  )

;;;;;;;;;;;;;;;;;
;; Small langs ;;
;;;;;;;;;;;;;;;;;

;; JSON

;; A reformat tool for JSON (required by json-mode)
(use-package json-reformat
  :defer t)

;; Get the path to a JSON element in Emacs (required by json-mode)
(use-package json-snatcher
  :defer t)

(use-package json-mode
  :defer t
  :requires (json-reformat json-snatcher))

(use-package yaml-mode
  :defer t
  :hook
  (yaml-mode . (lambda ()
                 (define-key yaml-mode-map "\C-m" 'newline-and-indent)
                 (setq show-trailing-whitespace t)
                 (flyspell-prog-mode)
                 (superword-mode 1)))
  :mode
  (("\\.\\(yml\\|knd)\\)\\'" . yaml-mode)))

(use-package markdown-mode
  :defer t
  :ensure-system-package (markdown . "brew install markdown || sudo apt-get install markdown")
  :hook
  (markdown-mode . (lambda ()
                     (setq show-trailing-whitespace t)
                     ;;(flyspell-prog-mode)
                     ;;(superword-mode 1)
                     ))
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :config
  (setq markdown-fontify-code-blocks-natively t))

;;;;;;;;;;;;;;;;;;;;
;; dired settings ;;
;;;;;;;;;;;;;;;;;;;;

(setq dired-dwim-target t
      dired-recursive-deletes t
      dired-use-ls-dired nil
      delete-by-moving-to-trash t)

;;;;;;;;;;;;;;;;;
;; Programming ;;
;;;;;;;;;;;;;;;;;

(global-subword-mode 1)
(diminish 'subword-mode)

;; (use-package eldoc
;;   :hook (emacs-lisp-mode . turn-on-eldoc-mode)
;;   (lisp-interaction-mode . turn-on-eldoc-mode)
;;   (haskell-mode . turn-on-haskell-doc-mode)
;;   )

;;;;;;;;;;;;;
;; Haskell ;;
;;;;;;;;;;;;;

(defun format-haskell-buffer (cmd)
  "Formats haskell buffer using a CMD."
  (shell-command (format cmd buffer-file-name))
  (revert-buffer :ignore-auto :noconfirm))

(defun ormolu ()
  "Format a haskell buffer using ormolu."
  (interactive)
  (format-haskell-buffer "ormolu -o -XTypeApplications --mode inplace %s"))

(defun format-haskell-buffer-on-save ()
  "Function formats haskell buffer on save."
  (when (eq major-mode 'haskell-mode)
    (ormolu)))

(add-hook 'after-save-hook #'format-haskell-buffer-on-save)

(use-package attrap
  :defer t
  :bind (("C-x /" . attrap-attrap)))

;; Haskell mode
(use-package haskell-mode
  :after flyspell
  :bind
  (("C-c h i" . haskell-navigate-imports)
   :map haskell-mode-map
   ("C-," . haskell-move-nested-left)
   ("C-." . haskell-move-nested-right))
  :custom
  (haskell-indent-spaces 2)
  :config
  (turn-on-haskell-indentation)
  (haskell-auto-insert-module-template)
  (haskell-decl-scan-mode)
  )

;; (use-package speedbar
;;   :config
;;   (speedbar-add-supported-extension ".hs")
;;   ;; start speedbar if we're using a window system
;;   ;; (when window-system 
;;   ;;   (speedbar t))
;;   )

;; ;; Same-frame speedbar
;; (use-package sr-speedbar
;;   :init
;;   (set-variable 'sr-speedbar-right-side nil)
;;   :bind (("s-S" . sr-speedbar-toggle)
;;          ("s-s" . sr-speedbar-select-window))
;;   )

(setq flymake-no-changes-timeout nil)
(setq flymake-start-syntax-check-on-newline nil)
(setq flycheck-check-syntax-automatically '(save mode-enabled))

;; (add-hook 'dante-mode-hook
;;           '(lambda () (flycheck-add-next-checker 'haskell-dante
;;                                             '(warning . haskell-hlint))))

;; (use-package dante
;;   :after haskell-mode
;;   :commands 'dante-mode
;;   :init
;;   (setq dante-load-flags '(;; defaults:
;;                            "+c"
;;                            "-Wwarn=missing-home-modules"
;;                            "-fno-diagnostics-show-caret"
;;                            ;; neccessary to make attrap-attrap useful:
;;                            "-Wall"
;;                            ))
;;   (add-hook 'haskell-mode-hook 'flycheck-mode)
;;   (add-hook 'haskell-mode-hook 'dante-mode))

;;;;;;;;;;;;;;;;;
;; Fennel mode ;;
;;;;;;;;;;;;;;;;;

(autoload 'fennel-mode "~/dev/emacs/fennel-mode/fennel-mode" nil t)
(customize-save-variable 'fennel-mode-switch-to-repl-after-reload nil)

(add-to-list 'auto-mode-alist '("\\.fnl\\'" . fennel-mode))

(defun run-love ()
  (interactive)
  (run-lisp "love ."))

(defun fennel-mode-hook-fun ()
  (interactive)
  (slime-mode nil))

(add-hook 'fennel-mode-hook 'fennel-mode-hook-fun)

;;;;;;;;;;;;;;;
;; Art-files ;;
;;;;;;;;;;;;;;;

(add-to-list 'auto-mode-alist '("\\.art\\'" . js-mode))

;;;;;;;;;;;;;;
;; Org mode ;;
;;;;;;;;;;;;;;

(defun next-org-slide ()
  "Show the next slide."
  (interactive)
  (widen)
  (org-next-visible-heading 1)
  (org-narrow-to-subtree))

;(global-set-key (kbd "C-c n") 'next-org-slide)

(defun prev-org-slide ()
  "Show the previous slide."
  (interactive)
  (widen)
  (org-previous-visible-heading 1)
  (org-narrow-to-subtree))

;(global-set-key (kbd "C-c p") 'prev-org-slide)

;;;;;;;;;;;;;;;;
;; Font icons ;;
;;;;;;;;;;;;;;;;

(use-package all-the-icons
  :init (unless (member "all-the-icons" (font-family-list))
          (all-the-icons-install-fonts t)))

;;;;;;;;;;
;; TODO ;;
;;;;;;;;;;

(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; - Probably set a keybinding for finding file in project using cousel-git

;;;;;

(provide 'init)
;;; init.el ends here

