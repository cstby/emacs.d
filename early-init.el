;;; early-init.el --- -*- lexical-binding: t; -*-

;;; Commentary:
;; This file is loaded before the package system and GUI are initialized.

;;; Code:

;; Increase garbage collection threshold temporarily to speed up initialization.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1)

;; Skipping a bunch of regular expression searching should improve start time.
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore
(add-hook 'elpaca-after-init-hook
          #'(lambda ()
              (setq file-name-handler-alist default-file-name-handler-alist
                    gc-cons-percentage 0.1
                    gc-cons-threshold 100000000)
              (message "Restored gc-cons-threshold & file-name-handler-alist")))

(add-hook 'elpaca-after-init-hook
          (lambda ()
            (message "Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract (current-time) before-init-time)))
                     gcs-done)))

;; Disable unwanted user interface elements.
(setq-default default-frame-alist
              '((menu-bar-mode        . 0)
                (tool-bar-lines       . 0)
                (menu-bar-lines       . 0)
                (vertical-scroll-bars . nil)
                ;; (left-fringe          . 0)
                ;; (right-fringe         . 0)
                (font                 . "Cabin-12")))

;; Configure user interface elements specific to macOS.
(when (eq system-type 'darwin)
  (push '(fullscreen . fullscreen) default-frame-alist)
  (push '(ns-transparent-titlebar . t) default-frame-alist)
  (push '(ns-appearance . dark) default-frame-alist)
  (setq frame-title-format "")
  (setq ns-use-proxy-icon nil))

;; Implicitly resizing the Emacs frame adds to init time.
(setq frame-inhibit-implied-resize t)

;; Prevent instructions on how to close an emacsclient frame.
(setq server-client-instructions nil)

;; Package loading won't be handled by package.el
(setq package-enable-at-startup nil)

;; These native-comp errors can be safely ignored.
(setq native-comp-async-report-warnings-errors nil)

(provide 'early-init)
;;; early-init.el ends here
