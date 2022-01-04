;;; early-init.el --- -*- lexical-binding: t; -*-

;;; Commentary:
;; This file is loaded before the package system and GUI are initialized.

;;; Code:

;; Increase garbage collection threshold temporarily to speed up initialization.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          #'(lambda ()
              (message "Emacs ready in %.2f seconds with %d garbage collections."
                       (float-time (time-subtract after-init-time before-init-time))
                       gcs-done)
              (setq gc-cons-threshold 20000000
                    gc-cons-percentage 0.1)))

;; Disable unwanted user interface elements.
(setq-default default-frame-alist
              '((menu-bar-mode        . 0)
                (tool-bar-lines       . 0)
                (menu-bar-lines       . 0)
                (vertical-scroll-bars . nil)
                (left-fringe          . 0)
                (right-fringe         . 0)
                (font                 . "Cabin-12")))

;; Configure user interface elements specific to macOS.
(when (eq system-type 'darwin)
  (push '(fullscreen . fullscreen) default-frame-alist)
  (push '(ns-transparent-titlebar . t) default-frame-alist)
  (push '(ns-appearance . dark) default-frame-alist)
  (setq frame-title-format "")
  (setq ns-use-proxy-icon nil))

;; Package loading is handled by straight.el.
(setq package-enable-at-startup nil)

(provide 'early-init)
;;; early-init.el ends here
