;;; early-init.el --- -*- lexical-binding: t -*-

;; Turn off GC for startup.
(setq gc-cons-threshold 100000000)

(setq package-enable-at-startup nil)

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq site-run-file nil)

;; Minimal UI
(scroll-bar-mode -1)
;(menu-bar-mode -1)
(tool-bar-mode -1)

(provide 'early-init)
