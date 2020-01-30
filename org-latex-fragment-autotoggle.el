;;; org-latex-fragment-autotoggle.el --- Automatically toggle org latex fragments

;; Copyright (C) 2020 Benjamin Levy
;; Author: Benjamin Levy <blevy@protonmail.com>
;; Description: Automatically toggle org-mode latex fragment previews as the cursor enters and exits them
;; Homepage: https://github.com/io12/org-latex-fragment-autotoggle
;; Package-Requires: (org)

;;; Code:

;;;###autoload
(define-minor-mode org-fragtog-mode
  "Toggle Org Latex Fragment Autotoggle Mode, a minor mode that automatically
toggles org-mode latex fragment previews as the cursor enters and exits them"
  nil nil nil
  (when (eq 'org-mode major-mode)
    (add-hook 'post-command-hook 'org-fragtog--post-cmd)))

(defvar org-fragtog--prev-frag
  nil
  "Previous fragment that surrounded the cursor. This is used to track when the
cursor leaves a fragment.")

(defun org-fragtog--post-cmd ()
  "This function runs in post-command-hook in org-fragtog-mode. It handles
toggling fragments depending on whether the cursor entered or exited them."
  (let* ((prev-frag org-fragtog--prev-frag)
	 (cursor-frag (org-fragtog--cursor-frag))
	 (frag-same (equal
		     (org-element-property :begin cursor-frag)
		     (org-element-property :begin prev-frag)))
	 (frag-changed (not frag-same)))
    ;; Only do anything if the current fragment changed
    (when frag-changed
      ;; Current fragment is the new previous
      (setq org-fragtog--prev-frag cursor-frag)
      ;; Enable fragment if cursor left it
      (when prev-frag
	(org-fragtog--enable-frag prev-frag))
      ;; Disable fragment if cursor entered it
      (when cursor-frag
	(org-fragtog--disable-frag cursor-frag)))))

(defun org-fragtog--cursor-frag ()
  "Returns the fragment currently surrounding the cursor, or nil if it does not
exist"
  (let*
      ;; Element surrounding the cursor
      ((elem (org-element-context))
       ;; Type of element surrounding the cursor
       (elem-type (car elem))
       ;; A latex fragment or environment is surrounding the cursor
       (elem-is-latex (member elem-type '(latex-fragment latex-environment))))
    (if elem-is-latex
	elem
      nil)))

(defun org-fragtog--enable-frag (frag)
  "TODO: docs"
  (remove-hook 'post-command-hook 'org-fragtog--post-cmd)
  (org-fragtog--disable-frag frag)
  (save-excursion
    (goto-char (org-element-context :begin frag))
    (org-latex-preview))
  (add-hook 'post-command-hook 'org-fragtog--post-cmd))

(defun org-fragtog--disable-frag (frag)
  "TODO: docs"
  (org-clear-latex-preview (org-element-property :begin frag)
			   (org-element-property :end frag)))

;;; org-latex-fragment-autotoggle.el ends here
