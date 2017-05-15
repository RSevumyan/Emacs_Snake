
;;==============================================================================================================================================================
;;====================================================================Snake game================================================================================
;;==============================================================================================================================================================
(defvar snake-position nil)
(defvar direction nil)
(defvar snake-timer nil)
(defvar food-position nil)

(defun snake-game ()
  (interactive)
  (let ((-buf (generate-new-buffer-name "snake-game")))
    (switch-to-buffer -buf))
  (snake-mode)
  (setq boxsize (read-number "Input box size: " 40))
  (create-game-box boxsize)
  (start-snake-game)
  )

(defun start-snake-game()
  (setq direction 6)
  (create-snake)
  (print-snake)
  (create-food)
  (move-snake-timer)
  )

(defun move-snake-timer()
  (when (timerp snake-timer)
    (cancel-timer snake-timer)   )
  (setq snake-timer (run-with-timer 0.13 0.13 'move-snake))  
  )

(defun create-game-box (boxsize)
  (let ((i 0))
    (while (< i boxsize)
      (setq i (+ i 1))
      (insert "\s_")
      )
    (newline)
    (setq i 0)
    (while (< i boxsize)
      (setq i (+ 1 i))
      (insert "|")
      (let ((j 0))
	(while (< j (- (* 2 boxsize) 1))
	  (setq j (+ j 1))
	  (insert "\s")
	  )
	)
      (insert "|")
      (newline)
      )
  
    (setq i 0)
    (while (< i boxsize)
      (setq i (+ i 1))
      (insert "\s")
      (insert-char 175)
      )
    )
  )

(defun create-snake()
  (let ((x (- boxsize 1)) (y (/ boxsize 2)))
    (setq snake-position (list (cons x y)))
    (setcdr (last snake-position) (list(cons (- x 2) y)))
    (setcdr (last snake-position) (list(cons (- x 4) y)))
    )
  )

(defun move-snake()
  (let (newposition)
    (when (= direction 2)
	(setq newposition (cons (caar snake-position)  (+ (cdar snake-position) 1)))
      )
    (when (= direction 4)
	(setq newposition  (cons (- (caar snake-position) 2) (cdar snake-position)))
      )
    (when (= direction 6)
	(setq newposition  (cons (+ (caar snake-position) 2) (cdar snake-position)))
      )
    (when (= direction 8)
	(setq newposition  (cons  (caar snake-position)  (- (cdar snake-position) 1)))
      )
    (if (and (< (car newposition) (* boxsize 2))
	     (<= (cdr newposition) (+ boxsize 1))
	     (>= (car newposition) 1) (> (cdr newposition) 1)
	     )
	(progn
	  (if (and (= (car newposition) (car food-position)) (= (cdr newposition) (cdr food-position)))
	      (eat-food)
	    (delete-snake-lastposition)
	    )
	  (add-snake-newposition newposition)
	  )
      (when (> (length snake-position) 1) (delete-snake-lastposition))
      )
    )
  (message "Your score: %d" (length snake-position))
  )

(defun print-snake()
  (dolist (pos snake-position)
    (goto-line (cdr pos))
    (move-to-column (car pos) )
    (delete-char 1)
    (insert "o")
    )
  (goto-line (cdar snake-position))
  (move-to-column (caar snake-position) )
  (delete-char 1)
  (insert-char 42601)
  )

(defun add-snake-newposition(newposition)
  (goto-line (cdar snake-position))
  (move-to-column (caar snake-position))
  (delete-char 1)
  (insert "o")
  (add-to-list 'snake-position newposition)
  (goto-line (cdar snake-position))
  (move-to-column (caar snake-position) )
  (delete-char 1)
  (insert-char 42601)
  )

(defun delete-snake-lastposition()
  (let ((lastposition (last snake-position)))
    (goto-line (cdar lastposition))
    (move-to-column (caar lastposition) )
    (delete-char 1)
    (insert "\s")
    )
  (nbutlast snake-position 1)
  )

(defun snake-move-up()
  (interactive)
  (if (/= direction 2)
      (progn
	(setq direction 8)
	(move-snake)
	)
    )
  (move-snake-timer)
  )

(defun snake-move-down()
  (interactive)
  (if (/= direction 8)
      (progn
	(setq direction 2)
	(move-snake)
	)
    )
  (move-snake-timer)
  )

(defun snake-move-right()
  (interactive)
  (if (/= direction 4)
      (progn
	(setq direction 6)
	(move-snake)
	)
    )
  (move-snake-timer)
  )

(defun snake-move-left()
  (interactive)
  (if (/= direction 6)
      (progn
	(setq direction 4)
	(move-snake)
	)
    )
  (move-snake-timer)
  )

(defun eat-food()
  (goto-line (cdr food-position))
  (move-to-column (car food-position))
  (delete-char 1)
  (insert "\s")
  (create-food)
  )

(defun create-food()
  (let ((flag 1))
    (while flag
       (let ((x) (y))
	 (setq x (+ (* (random boxsize) 2) 1))
	 (setq y (+ (random boxsize) 2))
	 (setq food-position (cons x y))
	 (when (not (member  food-position snake-position)) (setq flag nil))
	 ) 
       )
    )
  (goto-line (cdr food-position))
  (move-to-column (car food-position) )
  (delete-char 1)
  (insert "x")  
  )

(add-hook 'kill-buffer-hook (lambda () (when (timerp snake-timer) (cancel-timer snake-timer))))

(define-derived-mode snake-mode special-mode "snake-mode"
  (setq inhibit-read-only t)
  (setq cursor-type nil)
  (setq line-spacing 0)
  (define-key snake-mode-map (kbd "<right>") 'snake-move-right)
  (define-key snake-mode-map (kbd "<left>") 'snake-move-left)
  (define-key snake-mode-map (kbd "<up>") 'snake-move-up)
  (define-key snake-mode-map (kbd "<down>") 'snake-move-down)
)
