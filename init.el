;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;;; Code:

;; Produce backtraces when errors occur: can be helpful to diagnose startup issues
;;(setq debug-on-error t)

(let ((minver "24.5"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "25.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;;----------------------------------------------------------------------------
;; Adjust garbage collection thresholds during startup, and thereafter
;;----------------------------------------------------------------------------
(let ((normal-gc-cons-threshold (* 20 1024 1024))
      (init-gc-cons-threshold (* 128 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'diminish)
(maybe-require-package 'scratch)
(require-package 'command-log-mode)

(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-themes)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-smex)
(require 'init-ivy)
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)
(require 'init-sessions)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)

(require 'init-projectile)

(require 'init-compile)
(require 'init-crontab)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-html)
(require 'init-css)
(require 'init-haml)
(require 'init-http)
(require 'init-python)
(require 'init-haskell)
(require 'init-elm)
(require 'init-purescript)
(require 'init-ruby)
(require 'init-rails)
(require 'init-sql)
(require 'init-nim)
(require 'init-rust)
(require 'init-toml)
(require 'init-yaml)
(require 'init-docker)
(require 'init-terraform)
(require 'init-nix)
(maybe-require-package 'nginx-mode)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(require 'init-clojure)
(require 'init-clojure-cider)
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-misc)

(require 'init-folding)
(require 'init-dash)

;;(require 'init-twitter)
;; (require 'init-mu)
(require 'init-ledger)
;; Extra packages which don't require any configuration

(require-package 'sudo-edit)
(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(when *is-a-mac*
  (require-package 'osx-location))
(unless (eq system-type 'windows-nt)
  (maybe-require-package 'daemons))
(maybe-require-package 'dotenv-mode)
(maybe-require-package 'shfmt)

(when (maybe-require-package 'uptimes)
  (setq-default uptimes-keep-count 200)
  (add-hook 'after-init-hook (lambda () (require 'uptimes))))

(when (fboundp 'global-eldoc-mode)
  (add-hook 'after-init-hook 'global-eldoc-mode))

(require 'init-direnv)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(add-hook 'after-init-hook
          (lambda ()
            (require 'server)
            (unless (server-running-p)
              (server-start))))

;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)



(provide 'init)

;;----------------------------------------------------------------------------
;; customize
;;----------------------------------------------------------------------------

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

(require-package 'color-identifiers-mode)
(add-hook 'after-init-hook 'color-identifiers-mode)

(desktop-save-mode -1)
(set (make-local-variable 'electric-pair-mode) nil)

(require-package 'evil)
(evil-mode t)

;;(add-hook 'c-mode-hook
;; (function
;;  (lambda () (define-key evil-motion-state-map (kbd "C-i") 'evil-jump-forward))))
;;(add-hook 'org-mode-hook
;;  (function
;;  (lambda () (define-key evil-motion-state-map (kbd "C-i") 'org-cycle))))

(setq org-src-fontify-natively t)
(define-key evil-motion-state-map (kbd "SPC") 'org-cycle)

;;Enabling it may cause the emacs to lag
;;(global-nlinum-mode t)
;;(setq nlinum-highlight-current-line t)

;;默认显示80列换行
;;光标移动至有可能超出的行，M-q
(setq-default fill-column 80)

(global-hl-line-mode 1)
(set-face-background 'highlight "#222")
(set-face-foreground 'highlight nil)
(set-face-underline-p 'highlight t)

(require 'xcscope)
(cscope-setup)
;; redifne key 'o' 'n' 'p' which used by 'evil-mode'
(define-key cscope-list-entry-keymap (kbd "M-o") 'cscope-select-entry-one-window)
(define-key cscope-list-entry-keymap (kbd "M-n") 'cscope-history-forward-line)
(define-key cscope-list-entry-keymap (kbd "M-p") 'cscope-history-backward-line)

(setq x-select-enable-clipboard t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq c-default-style
   '((c-mode . "cc-mode")
     (other . "cc-mode")))

;; If emacs is run in a terminal, the clipboard- functions have no
;; effect. Instead, we use of xsel, see
;; http://www.vergenet.net/~conrad/software/xsel/ -- "a command-line
;; program for getting and setting the contents of the X selection"
(unless window-system
 (when (getenv "DISPLAY")
  ;; Callback for when user cuts
  (defun xsel-cut-function (text &optional push)
   ;; Insert text to temp-buffer, and "send" content to xsel stdin
   (with-temp-buffer
    (insert text)
    ;; I prefer using the "clipboard" selection (the one the
	    ;; typically is used by c-c/c-v) before the primary selection
    ;; (that uses mouse-select/middle-button-click)
    (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
  ;; Call back for when user pastes
  (defun xsel-paste-function()
   ;; Find out what is current selection by xsel. If it is different
   ;; from the top of the kill-ring (car kill-ring), then return
   ;; it. Else, nil is returned, so whatever is in the top of the
   ;; kill-ring will be used.
   (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
    (unless (string= (car kill-ring) xsel-output)
     xsel-output )))
  ;; Attach callbacks to hooks
  (setq interprogram-cut-function 'xsel-cut-function)
 (setq interprogram-paste-function 'xsel-paste-function)
 ;; Idea from
 ;; http://shreevatsa.wordpress.com/2006/10/22/emacs-copypaste-and-x/
 ;; http://www.mail-archive.com/help-gnu-emacs@gnu.org/msg03577.html
 ))

(define-advice show-paren-function (:around (fn) fix-show-paren-function)
  "Highlight enclosing parens."
  (cond ((looking-at-p "\\s(") (funcall fn))
	(t (save-excursion
	     (ignore-errors (backward-up-list))
	     (funcall fn)))))

(require-package 'helm-ag)
(custom-set-variables
  '(helm-ag-base-command "ag --nocolor --nogroup")
  '(helm-ag-command-option "--hidden --ignore *~ --ignore .git --ignore .idea"))
(global-set-key (kbd "M-s s") 'helm-do-ag-project-root)

(setq org-startup-with-inline-images t)

(setq org-image-actual-width nil)

;; 禁用下划线转义
;; 在org文件头部的 OPTIONS 里面添加 ^:nil:
;; 或者对所有文件生效
(setq-default org-use-sub-superscripts nil)

;; encoding utf-8
(set-language-environment "UTF-8")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)

(custom-set-variables '(initial-frame-alist (quote ((fullscreen . maximized)))))

;; org-mode 中的自动换行
(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))

;; 打开 tag 文件时，不发出警告
(setq large-file-warning-threshold nil)

;; 设置背景为 dark，解决 terminal eamcs 背景为蓝色的问题
(custom-set-variables
  '(default-frame-alist
     '((background-color . "#111111")
       (background-mode . dark))))

;; Ref: https://www.emacswiki.org/emacs/IndentingC
(setq c-default-style "linux"
      c-basic-offset 8)
(setq-default c-basic-offset 8
	      tab-width 8
	      indent-tabs-mode t)

;; 自动在 {} 中加入空行
;;(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state 1)))

;; 函数的多行参数对齐
(defun my-indent-setup ()
  (c-set-offset 'arglist-intro '+))
      (add-hook 'c-mode-common-hook 'my-indent-setup)

;Pressing TAB should cause indentation
(setq-default c-indent-tabs-mode t)

;; org-mode 保存时，删除行尾空格
(defun albert-org-mode-hook nil
  (add-hook 'before-save-hook 'delete-trailing-whitespace) t t)
(add-hook `org-mode-hook `albert-org-mode-hook)

(global-pangu-spacing-mode t)

;; 默认折叠 plain list
(setq org-cycle-include-plain-lists 'integrate)

;;org to html to pdf
;;CTRL+c CTRL+e h h
;;wkhtmltopdf a.html a.pdf

;; Setting Font
;; 解决中文卡顿的问题：
;; 使用 emcas GUI, 在菜单中选择默认的字体
;; 然后保存选择即可
;; 使用 'cnfonts' 不能解决问题。

;;----------------------------------------------------------------------------
;; customize End
;;----------------------------------------------------------------------------

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
;;; init.el ends here
