(in-package :lem-core)

(defvar *editor-event-queue* (make-concurrent-queue))

(defun event-queue-length ()
  (len *editor-event-queue*))

(defun dequeue-event (timeout)
  (dequeue *editor-event-queue* :timeout timeout :timeout-value :timeout))

(defun send-event (obj)
  (enqueue *editor-event-queue* obj))

(defun send-abort-event (editor-thread force)
  (bt:interrupt-thread editor-thread
                       (lambda ()
                         (lem-base::interrupt force))))

(defun receive-event (timeout)
  (loop
    (let ((e (dequeue-event timeout)))
      (cond ((null e)
             (return nil))
            ((eql e :timeout)
             (assert timeout)
             (return nil))
            ((eql e :resize)
             (when (>= 1 (event-queue-length))
               (update-on-display-resized)))
            ((consp e)
             (eval e)
             (return t))
            ((or (functionp e) (symbolp e))
             (funcall e))
            (t
             (return e))))))
