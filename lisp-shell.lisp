(set-macro-character #\?
                     (lambda (stream char)
                       (declare (ignore char))
                       (read stream nil)))

(set-macro-character #\$
                     (lambda (stream char)
                       (declare (ignore char))
                       (uiop/os:getenv (string (read stream nil)))))

(set-macro-character #\] (get-macro-character #\)))
(set-dispatch-macro-character #\# #\[
                              (lambda (stream char1 char2)
                                (declare (ignore char1 char2))
                                (setf (readtable-case *readtable*) :preserve)
                                (unwind-protect
                                     (let ((command-line (read-delimited-list
                                                          #\] stream t)))
                                       (list 'uiop/run-program:run-program
                                             (mkstr command-line)
                                             :output t
                                             :ignore-error-status t))
                                  (setf (readtable-case *readtable*) :upcase))))

(setf (fdefinition 'cd) #'uiop/os:chdir)
