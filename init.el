;;; init.el --- Cstby's Emacs Configuration -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Carl Steib

;;; Commentary:
;; This is my personal Emacs configuration.

;;; Code:

;; Bootstrap straight.el package manager.
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Replace use-package with straight-use-package.
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; Built-in packages
;;-------------------------------------------------

(use-package emacs
  :straight (:type built-in)
  :config
  (setq-default fill-column 80)
  ;; I use Clojure more often than elisp (default).
  (setq inhibit-splash-screen t
        initial-major-mode 'clojure-mode
        initial-scratch-message ";; This *scratch* buffer is for Clojure.\n\n")
  ;; The sound is an annoyance.
  (setq ring-bell-function 'ignore)
  ;; Never use tabs but render them according to elisp convention.
  (setq-default indent-tabs-mode nil
    tab-width 2)
  ;; Typing out yes/no is an inconvenience.
  (fset 'yes-or-no-p 'y-or-n-p)
  (global-set-key (kbd "C-w") #'kill-this-buffer)
  (global-set-key (kbd "M-k") #'kill-to-end-of-buffer)
  ;; Move to where text begins rather than the beginning of the line.
  (global-set-key [home] 'beginning-of-line-text)
  ;; Fix shift-tab on Linux.
  (define-key function-key-map [(control shift iso-lefttab)] [(control shift tab)])
  ;; Tailor command maps to Kinesis Advantage.
  (define-key key-translation-map (kbd "C-SPC") (kbd "C-c"))
  (define-key key-translation-map (kbd "C-<return>") (kbd "C-x"))
  (defun kill-to-end-of-buffer ()
    "Delete everything after defun at point."
    (interactive)
    (delete-region (cdr (bounds-of-thing-at-point 'defun)) (point-max)))
  (defun focus-window ()
    "Focus to single window or unfocus to original state."
    (interactive)
    (if (= 1 (length (window-list)))
        (jump-to-register '_)
      (progn
        (set-register '_ (list (current-window-configuration)))
        (delete-other-windows))))
  (defun clean-empty-lines ()
    "Remove duplicate empty lines."
    (interactive)
    (let ($begin $end)
      (setq $begin (point-min) $end (point-max))
      (save-excursion
        (save-restriction
          (narrow-to-region $begin $end)
          (progn
            (goto-char (point-min))
            (while (re-search-forward "\n\n\n+" nil "move")
              (replace-match "\n\n")))))))
  (add-hook 'before-save-hook 'clean-empty-lines)
  (defun reload-theme ()
    (interactive)
    (let ((themes custom-enabled-themes))
      (progn
        (mapc #'disable-theme themes)
        (mapc (lambda (theme) (load-theme theme t)) themes)
        (message "Reloaded themes: %S" themes))))
  (defun my-focus-new-client-frame (newly-created-frame)
    (when (daemonp)
      (select-frame-set-input-focus newly-created-frame)))
  (add-hook 'after-make-frame-functions #'my-focus-new-client-frame))

(use-package autorevert
  :straight (:type built-in)
  :config
  ;; Revert buffers automatically when underlying files are changed externally,
  ;; except for renames, deletes, and when the buffer has unsaved changes.
  (global-auto-revert-mode 1))

(use-package cus-edit
  :straight (:type built-in)
  :config
  ;; Loading the custom file undermines making this config declarative.
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory)))

(use-package cus-face
  :straight (:type built-in)
  :config
  ;; These faces will be used by fixed-pitch mode and others.
  (custom-set-faces '(fixed-pitch ((t (:family "Monego" :height 105))))
                    '(variable-pitch ((t (:family "Crimson Pro" :height 140))))))

(use-package dired
  :straight (:type built-in)
  :hook (dired-mode . dired-hide-details-mode)
  :config
  ;; Press 'a' to open directories in the current buffer.
  (put 'dired-find-alternate-file 'disabled nil))

(use-package files
  :straight (:type built-in)
  :config
  (setq require-final-newline t)
  (setq confirm-kill-processes nil)
  ;; Don't let backups and autosaves clutter my directories .
  (setq backup-directory-alist `((".*" . ,temporary-file-directory))
        auto-save-file-name-transforms `((".*" ,temporary-file-directory t))))

(use-package mwheel
  :straight (:type built-in)
  :config
  ;; Scroll one line at a time rather than five.
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil))

(use-package paren
  :straight (:type built-in)
  :config
  (setq show-paren-style 'mixed)
  (show-paren-mode 1))

(use-package simple
  :straight (:type built-in)
  :config
  (column-number-mode 1)
  (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode))

(use-package text-mode
  :straight (:type built-in)
  :config
  (add-hook 'text-mode-hook #'visual-line-mode))

(use-package whitespace
  :straight (:type built-in)
  :config
  (add-hook 'before-save-hook 'whitespace-cleanup))

;; Packages
;;-------------------------------------------------

(use-package ag)

(use-package aggressive-indent
  :config (global-aggressive-indent-mode 1))

(use-package all-the-icons)

(use-package all-the-icons-dired
  :config
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
  (setq all-the-icons-dired-monochrome nil))

(use-package all-the-icons-completion
  :config
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup))

(use-package centaur-tabs
  :demand t
  :config
  ;; If centaur tabs isn't enabled first, icons will not render.
  (centaur-tabs-mode 1)
  ;; The function bind-key* keeps other modes from clobbering the binding.
  (bind-key* "C-<tab>" 'centaur-tabs-forward)
  (bind-key* "C-S-<tab>" 'centaur-tabs-backward)
  (setq centaur-tabs-cycle-scope 'tabs)
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-set-close-button nil)
  (setq centaur-tabs-set-bar nil)
  (defun centaur-tabs-buffer-groups ()
    "Return the list of group names BUFFER belongs to. Return only one group for each buffer."
    (if centaur-tabs-projectile-buffer-group-calc
        (symbol-value 'centaur-tabs-projectile-buffer-group-calc)
      (set (make-local-variable 'centaur-tabs-projectile-buffer-group-calc)
           (cond
            ((memq major-mode '(fundamental-mode)) '("Fundamental"))
            ((string-prefix-p "*ci" (buffer-name)) '("Cider"))
            ((string-prefix-p "*" (buffer-name)) '("Misc"))
            ((condition-case _err (projectile-project-root) (error nil)) (list (projectile-project-name)))
            ((memq major-mode '(emacs-lisp-mode)) '("Elisp"))
            ((memq major-mode '(org-mode calendar-mode diary-mode)) '("Org"))
            ((memq major-mode '(dired-mode)) '("Dir"))
            (t '("Other"))))
      (symbol-value 'centaur-tabs-projectile-buffer-group-calc))))

(use-package cider
  :config
  ;; Make eval-to-comment easier to handle.
  (setq cider-comment-prefix "#_"
        cider-comment-continued-prefix "   "
        cider-comment-postfix "\n")
  ;; I mostly interact with the repl from within the file buffer.
  (setq nrepl-hide-special-buffers t
        cider-repl-pop-to-buffer-on-connect 'display-only
        cider-invert-insert-eval-p t
        cider-switch-to-repl-on-insert nil)
  ;; Run namespace tests whenever file is loaded.
  (cider-auto-test-mode 1)
  ;; Font lock
  (setq cider-font-lock-dynamically nil)
  ;; Test reports don't reliably render in the echo area.
  (setq cider-test-show-report-on-success t)
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'lispy-mode)
  (add-hook 'cider-repl-mode-hook #'eldoc-mode)
  ;; Use existing windows for test reports and stack traces.  Centaur-tabs will
  ;; group these reports into the right window if one is open.
  (add-hook 'cider-test-report-mode-hook (lambda () (setq pop-up-windows nil)))
  (add-hook 'cider-stacktrace-mode-hook (lambda () (setq pop-up-windows nil)))
  (defun cider-eval-n-defuns (n)
    "Evaluate N forms, starting with the current one."
    (interactive "P")
    (cider-eval-region (car (bounds-of-thing-at-point 'defun))
                       (save-excursion
                         (dotimes (i (or n 2))
                           (end-of-defun))
                         (point)))))

(use-package cider-eval-sexp-fu)

(use-package clojure-mode
  :config
  (setq clojure-align-forms-automatically t))

(use-package clojure-mode-extra-font-locking
  ;; Unlike cider, this uses the builtin face for clojure.core.
  :config
  (font-lock-add-keywords 'clojurescript-mode
                          `((,(concat "(\\(?:\.*/\\)?"
                                      (regexp-opt clojure-built-in-vars t)
                                      "\\>")
                             1 font-lock-builtin-face))))

(use-package clojure-snippets)

(use-package company
  :config
  (setq company-idle-delay 0
        company-show-numbers t
        company-tooltip-align-annotations t
        company-minimum-prefix-length 2)
  (global-set-key (kbd "TAB") #'company-indent-or-complete-common)
  (global-company-mode 1))

(use-package company-prescient
  :config (company-prescient-mode 1))

(use-package company-quickhelp
  :config (company-quickhelp-mode 1))

(use-package consult
  :bind
  (("C-." . consult-imenu-multi))
  (("C-x b" . consult-buffer)))

(use-package cua-base
  ;; Must be loaded after general so that C-c isn't clobbered.
  :after (general)
  :config
  ;; Use undo-fu instead.
  (setq cua-remap-control-z nil)
  (cua-mode 1))

(use-package dired-subtree
  :config
  (bind-keys :map dired-mode-map
             ("i" . dired-subtree-insert)
             (";" . dired-subtree-remove)))

(use-package doom-modeline
  :demand t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-buffer-modification-icon nil)
  (setq doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-def-modeline 'my-simple-line
    '(matches buffer-info remote-host buffer-position selection-info)
    '(misc-info minor-modes input-method process vcs checker major-mode))
  (defun setup-custom-doom-modeline ()
    (doom-modeline-set-modeline 'my-simple-line 'default))
  (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline))

(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package easy-kill
  :config
  (global-set-key [remap kill-ring-save] 'easy-kill))

(use-package embark
  :bind
  (("C-`" . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings))

  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult))

(use-package fixed-pitch
  :straight (:local-repo "~/.emacs.d/my-packages/fixed-pitch/")
  :config
  (setq-default cursor-type 'bar))

(use-package flycheck
  :config (global-flycheck-mode 1))

(use-package flycheck-package)

(use-package flyspell
  :config
  (define-key flyspell-mode-map (kbd "C-.") nil)
  ;; GNU Aspell was designed to replace Ispell (default).
  (setq ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra"))
  (add-hook 'text-mode-hook #'flyspell-mode)
  (add-hook 'prog-mode-hook #'flyspell-prog-mode))

(use-package forge
  :after magit)

(use-package general
  :config
  (general-define-key
   :keymaps 'override
   :prefix "C-c"
   "SPC" 'execute-extended-command
   "&" 'async-shell-command
   "%" 'query-replace
   ":" 'eval-expression
   "<" 'beginning-of-buffer
   ">" 'end-of-buffer
   "I" '(lambda () (interactive) (find-file user-init-file))
   "c" '(:which-key "cider")
   ;; cider command maps
   "cd" 'cider-doc-map
   "c=" 'cider-profile-map
   "cn" 'cider-ns-map
   "ct" 'cider-test-commands-map
   "cv" 'cider-eval-commands-map
   "cj" 'cider-insert-commands-map
   "cs" 'sesman-map
   "cx" 'cider-start-map
   ;; cider functions
   "c." 'cider-eval-defun-up-to-point
   "cg" 'cider-eval-n-defuns
   "c;" 'cider-pprint-eval-defun-to-comment
   "g" '(:which-key "git")
   "gs" 'magit-status
   "gb" 'magit-blame
   "gl" 'magit-list-repositories
   "j" '(:which-key "jump")
   "jb" 'xref-go-back
   "jg" 'xref-find-definitions
   "jo" 'dumb-jump-go-other-window
   "jp" 'dumb-jump-go-prompt
   "jl" 'dumb-jump-quick-look
   "l" 'lsp-command-map
   "n" '(:which-key "norby")
   "nd" 'norby-dev
   "np" 'norby-prod
   "p" 'projectile-command-map
   "w" '(:which-key "window")
   "wb" 'balance-windows
   "wo" 'switch-to-buffer-other-window
   "wf" 'focus-window
   "wF" 'toggle-frame-fullscreen
   "wh" 'split-window-horizontally
   "wv" 'split-window-vertically
   "wd" 'delete-window
   "wt" 'transpose-frame
   "wn" 'switch-to-buffer-other-window))

(use-package hungry-delete
  :config (global-hungry-delete-mode 1))

(use-package imenu-anywhere)

(use-package lispy
  :config
  (defun lispy-out (arg)
    (interactive "p")
    (if (lispy-right-p)
        (lispy-right 1)
      (lispy-left 1)))
  (defun lispy-end-of-defun (arg)
    (interactive "p")
    (lispy-beginning-of-defun)
    (lispy-different))
  (setq lispy-safe-delete t
        lispy-thread-last-macro "->>")
  ;; Configure avy to Dvorak and not shift the damn text around.
  (setq lispy-avy-style-paren 'at-full
        lispy-avy-style-symbol 'at-full
        lispy-avy-keys '(?a ?e ?o ?u ?h ?t ?n ?s)
        avy-background t)
  ;; Make lispy navigation more sensible and suitable for Dvorak.
  (lispy-define-key lispy-mode-map (kbd "h") 'lispy-up)
  (lispy-define-key lispy-mode-map (kbd "t") 'lispy-flow)
  (lispy-define-key lispy-mode-map (kbd "n") 'lispy-out)
  (lispy-define-key lispy-mode-map (kbd "s") 'lispy-down)
  (lispy-define-key lispy-mode-map (kbd "p") 'lispy-ace-paren)
  (lispy-define-key lispy-mode-map (kbd "j") 'lispy-teleport)
  (lispy-define-key lispy-mode-map (kbd "k") 'lispy-new-copy)
  (lispy-define-key lispy-mode-map (kbd "l") 'lispy-move-down)
  ;; Lispy clobbers some global keybindings, so rebinding them in the
  ;; lispy-mode-map is an ugly necessity.
  (define-key lispy-mode-map (kbd "<M-right>") 'windmove-right)
  (define-key lispy-mode-map (kbd "<M-left>") 'windmove-left)
  (define-key lispy-mode-map (kbd "<home>") 'lispy-left)
  (define-key lispy-mode-map (kbd "<end>") 'lispy-right)
  (define-key lispy-mode-map (kbd "<M-home>") 'lispy-beginning-of-defun)
  (define-key lispy-mode-map (kbd "<M-end>") 'lispy-end-of-defun)
  (define-key lispy-mode-map (kbd "C-)") 'lispy-forward-slurp-sexp)
  (define-key lispy-mode-map (kbd "M-r") 'lispy-splice-sexp-killing-backward)
  (define-key lispy-mode-map (kbd "<deletechar>") 'lispy-delete)
  (define-key lispy-mode-map (kbd "M-s") 'lispy-splice)
  (define-key lispy-mode-map (kbd "M-k") 'kill-to-end-of-buffer)
  (define-key lispy-mode-map (kbd "M-a") 'lispy-beginning-of-defun)
  (define-key lispy-mode-map (kbd "[") 'lispy-brackets)
  (define-key lispy-mode-map (kbd "M-p") (lambda () (interactive) (lispy-ace-paren -1)))
  ;; Unfortunately, no general lisp hook exists.
  (add-hook 'emacs-lisp-mode-hook #'lispy-mode)
  (add-hook 'clojure-mode-hook #'lispy-mode)
  (add-hook 'scheme-mode-hook #'lispy-mode)
  (add-hook 'racket-mode-hook #'lispy-mode)
  ;; Enabling cider compatibility shows a warning if not placed here.
  (setq lispy-compat 'cider))

(use-package lsp-mode
  :hook ((clojure-mode . lsp)
         (clojurec-mode . lsp)
         (clojurescript-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-enable-indentation nil)
  (fset 'lsp-command-map lsp-command-map)
  (dolist (m '(clojure-mode
               clojurec-mode
               clojurescript-mode
               clojurex-mode))
    (add-to-list 'lsp-language-id-configuration `(,m . "clojure"))))

(use-package magit
  :config
  (setq magit-diff-refine-hunk 'all)
  (define-key magit-section-mode-map [remap forward-paragraph] 'magit-section-forward)
  (define-key magit-section-mode-map [remap backward-paragraph] 'magit-section-backward))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  ;; Marginalia's README specifies that activation must be eager.
  :init
  (marginalia-mode 1))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :config
  ;; Visual-line-mode will trigger visual-column-mode.
  (add-hook 'gfm-mode-hook #'visual-line-mode)
  (add-hook 'gfm-mode-hook #'variable-pitch-mode)
  ;; Leave all the markup but scale headers.
  (setq markdown-header-scaling nil
        markdown-fontify-code-blocks-natively t))

(use-package modus-themes)

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package org
  :init
  (add-hook 'org-mode-hook #'variable-pitch-mode)
  :config
  ;; Keep my conventional selection please.
  (setq org-support-shift-select t)
  ;; Hide all markup.
  (setq org-hide-emphasis-markers t)
  ;; Give me back my keybindings please.
  (define-key org-mode-map (kbd "C-<tab>") nil)
  (define-key org-mode-map (kbd "M-<right>") nil)
  (define-key org-mode-map (kbd "M-<left>") nil)
  ;; Don't fold content automatically.
  (setq org-startup-folded nil)
  ;; Align body text with header, which is indented.
  (setq org-startup-indented t))

(use-package org-bullets
  :config
  (setq org-bullets-bullet-list '("⮚"))
  (add-hook 'org-mode-hook #'org-bullets-mode))

(use-package package-lint)

(use-package prescient
  :config (prescient-persist-mode 1))

(use-package projectile
  :config (projectile-mode 1))

(use-package rainbow-mode
  :hook prog-mode)

(use-package recentf
  :config
  (setq recentf-max-saved-items 50
        recentf-auto-cleanup 'never)
  (recentf-mode 1))

(use-package selectrum
  :config
  (setq selectrum-should-sort-p t
        selectrum-count-style 'current/matches)
  ;; Enable cua bindings in minibuffer.
  (define-key selectrum-minibuffer-map [prior] #'selectrum-previous-page)
  (define-key selectrum-minibuffer-map [next] #'selectrum-next-page)
  (selectrum-mode 1))

(use-package selectrum-prescient
  :config (selectrum-prescient-mode 1))

(use-package slack-slash
  :straight (:type git :host github :repo "cstby/emacs-slack-slash")
  :config
  (load "~/clj-slack/swing-clj"))

(use-package solo-jazz-theme
  :straight (:local-repo "~/.emacs.d/my-packages/solo-jazz-emacs-theme/")
  :config
  ;; Adding the theme path allows me to hot-reload the theme.
  (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/solo-jazz-emacs-theme/")
  (load-theme 'solo-jazz t)
  (advice-add 'rainbow-turn-on :after #'solo-jazz-theme-rainbow-turn-on)
  (advice-add 'rainbow-turn-off :after #'solo-jazz-theme-rainbow-turn-off))

(use-package sotclojure
  :config
  (speed-of-thought-mode 1)
  (sotclojure-mode 1))

(use-package sublimity
  :config
  (require 'sublimity)
  (require 'sublimity-scroll)
  (setq sublimity-scroll-weight 12
        sublimity-scroll-drift-length 8)
  (sublimity-mode 1))

(use-package transpose-frame)

(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(use-package visual-fill-column
  :config
  (add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
  (setq-default visual-fill-column-center-text nil))

(use-package web)

(use-package web-mode
  :config
  (setq web-mode-enable-current-column-highlight t)
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode)))

(use-package which-key
  :config (which-key-mode 1))

(use-package windmove
  :config
  (windmove-default-keybindings 'meta))

(use-package yasnippet
  :config
  (setq yas-triggers-in-field t
        yas-verbosity 1)
  (yas-global-mode 1))

(use-package xref)

(use-package zenburn-theme)

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:
