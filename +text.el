;;;  -*- lexical-binding: t; -*-

(add-hook! 'text-mode-hook (setq-local truncate-lines nil))

(add-hook! 'org-mode-hook (org-bullets-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ORG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! org
  (setq org-directory (expand-file-name "~/org-notes")

        org-agenda-files (list org-directory)

        org-ellipsis " ▼ "

        org-babel-python-command "python3"

        org-bullets-bullet-list '("☰" "☱" "☲" "☳" "☴" "☵" "☶" "☷")

        org-log-done 'time

        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)" "CANCELED(c)")))
  )

(after! org
  (setq org-capture-templates
        '(("t" "Personal todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           "* TODO %?\n%i" :prepend t :kill-buffer t)
          ("n" "Personal notes" entry
           (file+headline +org-capture-notes-file "Inbox")
           "* %u %?\n%i" :prepend t :kill-buffer t)

          ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
          ;; {todo,notes,changelog}.org file is found in a parent directory.
          ("p" "Templates for projects")
          ("pt" "Project todo" entry    ; {project-root}/todo.org
           (file+headline +org-capture-project-todo-file "Inbox")
           "* TODO %?\n%i" :prepend t :kill-buffer t)
          ("pn" "Project notes" entry   ; {project-root}/notes.org
           (file+headline +org-capture-project-notes-file "Inbox")
           "* TODO %?\n%i" :prepend t :kill-buffer t)
          ("pc" "Project changelog" entry ; {project-root}/changelog.org
           (file+headline +org-capture-project-notes-file "Unreleased")
           "* TODO %?\n%i" :prepend t :kill-buffer t)))

  (setq org-agenda-custom-commands
        '(
          ("n" "Agenda and all TODOs"
           ((agenda "")
            (alltodo "")))
          ("g" . "GTD contexts >>>>")
          ("go" "Office" tags-todo "@office"
           ((org-agenda-view-columns-initially t)))
          ("gh" "Home" tags-todo "@home"
           ((org-agenda-view-columns-initially t)))
          ("gr" "Reading" tags-todo "reading"
           ((org-agenda-view-columns-initially t)))
          ("G" "GTD Block Agenda"
           ((tags-todo "@office")
            (tags-todo "@home"))
           ((org-agenda-view-columns-initially t))
           ("~/next-actions.html"))
          ("i" "Inbox" alltodo ""
           ((org-agenda-files '("~/gtd/inbox.org")))
           )
          ))

  (setq org-log-into-drawer "LOGBOOK")


  ;; Schedule/deadline popup with default time
  (defvar org-default-time "10:30"
    "The default time for deadlines.")

  (defun advise-org-default-time (func arg &optional time)
    (let ((old-time (symbol-function #'org-read-date)))
      (cl-letf (((symbol-function #'org-read-date)
                 #'(lambda (&optional a b c d default-time f g)
                     (let ((default-time (or default-time
                                             org-default-time)))
                       (apply old-time a b c d f default-time g)
                       ))))
        (apply func arg time))))

  (advice-add #'org-deadline :around #'advise-org-default-time)
  (advice-add #'org-schedule :around #'advise-org-default-time))


;; (use-package! org-wild-notifier
;;   :defer t
;;   :init
;;   (add-hook 'doom-after-init-modules-hook #'org-wild-notifier-mode t)
;;   :config
;;   (setq org-wild-notifier-alert-time 5
;;         alert-default-style (if IS-MAC 'osx-notifier 'libnotify)))


(after! ox-pandoc
  (setq org-pandoc-options-for-revealjs '((variable . "highlight-theme=github")
                                          (variable . "theme=white"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MARKDOWN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(remove-hook 'text-mode-hook #'auto-fill-mode)


(use-package! edit-indirect :defer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OTHERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! blog-admin
  :defer t
  :commands blog-admin-start
  :hook (blog-admin-backend-after-new-post . find-file)
  :init
  ;; do your configuration here
  (setq blog-admin-backend-type 'hexo
        blog-admin-backend-path "~/Developer/Github/hexo_blog"
        blog-admin-backend-new-post-in-drafts t
        blog-admin-backend-new-post-with-same-name-dir nil
        blog-admin-backend-hexo-config-file "_config.yml"))

(use-package! youdao-dictionary
  :defer t
  :config
  ;; Enable Cache
  (setq url-automatic-caching t
        ;; Set file path for saving search history
        youdao-dictionary-search-history-file
        (concat doom-cache-dir ".youdao")
        ;; Enable Chinese word segmentation support
        youdao-dictionary-use-chinese-word-segmentation t))

(use-package! tldr
  :defer t
  :config
  (setq tldr-directory-path (concat doom-etc-dir "tldr/"))
  (set-popup-rule! "^\\*tldr\\*" :side 'right :select t :quit t)
  )

(use-package! link-hint :defer t)

(use-package! symbol-overlay :defer t)

(after! so-long
  (setq so-long-target-modes (delete 'text-mode so-long-target-modes)))


(use-package! adoc-mode
  :defer t
  :init
  (add-to-list 'auto-mode-alist (cons "\\.adoc\\'" 'adoc-mode)))
