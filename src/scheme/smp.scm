#lang scheme
; ___________________________________________________________________ PRIMARY FUNCTIONS ___________________________________________________________________________________


; Main function
; Takes two strings that reference the names of the csv files
; calls parseCSV function to turn the CSV into a list before starting to send offers
; ML = Match List
; 1 = iterator
(define (stableMatching employerFile studentFile)
  (sendOffers (parseCSV employerFile) (parseCSV studentFile) '() 1))


; EPL = Employer's Preference List (("Industry Canada" "Lucas" ...) ("you.i" "Lucas" ...) ("Ford" ....) .....)
; SPL = Student's Preference List (("Ali" "Inudstry Canada" "Cisco" ...) ("Lucas" "Ford" ...) ("Kat" ....) .....)
; ML = Match List
; i = iterator
(define (sendOffers EPL SPL ML i)
  (cond
    ; iterator has reached the end the list
    ; call create CSV File using the reversed version of ML
    ((>= i 11) (writeCSV "matches_10x10.csv" (reverse ML)))
    
    ; else, call function offer to the next employer in line
    ; (getIthSubItem EPL i) = Preference list of the next employer i
    ; Stores offer return value as the updated Match List
    ; Recursive call of sendOffer using updated matchlist as a new parameter
    (else (begin
           (let ((newMatchList (offer (getIthSubItem EPL i) SPL EPL ML 2))) ; 2 is the "position" of the FIRST student ("Ford" "FirstStudent" "SecondStudent" ....)
           (sendOffers EPL SPL newMatchList (+ i 1)))))
  )
)

; Offer function
; SEPL = Single Employer Preference List ("Ford" "FirstStudent" "SecondStudent" ....)
; SPL = Student's Preference List (all students)
; EPL = Employer's Preference List (all employers)
; ML = Match List
; i = iterator to keep track of next student to offer
; (car SEPL) = current Employer
(define (offer SEPL SPL EPL ML i)
  (cond
    ; If current employer is NOT matched
    ((not (hasMatch? (car SEPL) ML)) (begin
                                       ; nextStudent is the closest student that has yet to receive an offer from current employer
                                       ; newMatch is the next candidate match that will be used in evaluate()
                                       (let* ((nextStudent (getIthSubItem SEPL i))
                                             (newMatch (cons (car SEPL) (list nextStudent))))
                                        ; calls evaluate with newMatch, SEPL, SSPL (the preference list of the student in question), and other regular parameters
                                        (evaluate newMatch SEPL (getSubList nextStudent SPL) SPL EPL ML i)))))
)

; Evaluate function
; SEPL = Single Employer Preference List
; SSPL = Single Student Preference List
; (car SEPL) = Employer of the current new match we made
; (car SSPL) = Student of the current match we made
; (car (getStudentMatch (car SSPL) ML)) = Current employer that is matched with the current student
(define (evaluate NM SEPL SSPL SPL EPL ML i)
  (cond
    ; Student in question has not been matched, create match & end evaluate function
    ((not (hasMatch? (car SSPL) ML)) (cons NM ML))

    ; Fetch oldEmployer (the student's current match)
    ; Fetch newEmployer
    ; Check if student prefers newEmployer
    ((let ((oldEmployer (car (getStudentMatch (car SSPL) ML)))
           (newEmployer (car SEPL)))
           (cond
             ; Student prefers new Employer
             ; Find and replace oldEmployer with newEmployer & bind it to updatedML variable
             ; Fetch the preference list of the oldEmployer
             ; Call offer using oldEmployer preference list
             
             ; (+ 2 (returnRank (car SSPL) oldEmployerSEPL 0) = Iterator now points to the next potential student in line
             ((prefers? newEmployer oldEmployer SSPL) (let ((updatedML (subst newEmployer oldEmployer ML))
                                                             (oldEmployerSEPL (getSubList oldEmployer EPL)))
                                                              (offer oldEmployerSEPL SPL EPL updatedML (+ 2 (returnRank (car SSPL) oldEmployerSEPL 0)))))
             ; Student prefers old Employer
             ; call offer with the newEmployer
             ; iterator is now incremented by 1 to point to the next potential student
             (else (offer SEPL SPL EPL ML (+ i 1))))))
  )
)


; ___________________________________________________________________ CSV FUNCTIONS ___________________________________________________________________________________


; ParseCSV Function
; Takes a csv file name and returns a 2D list of string elements
; i.e '(("a" "b") ("c" "d") ("e" "f") ("g" "h") ("i" "j"))
; Uses str-split helper function
(define (parseCSV fileName)
  (define file (open-input-file fileName))
  (let loop ((line (read-line file)) (preferenceList '())) ; Here I am using Scheme's 'let name' feature 
    (cond
      ((eof-object? line) (reverse preferenceList))
      (else (loop (read-line file) (cons (str-split (car (string-split line)) #\,) preferenceList)))
     )
   )
)

; str-split Function
; Takes a string str (elements of the CSV file) and splits it (after every instance of 'ch') into a list of strings
; In this case, I am using it to remove all commas that seperate each Employer/Student
; i.e (str-split "This,Is,A,String" #\,) ==> ("This" "Is" "A" "String")
(define (str-split str ch)
  (let ((len (string-length str)))
    (letrec
      ((split
        (lambda (a b)
          (cond
            ((>= b len) (if (= a b) '() (cons (substring str a b) '())))
              ((char=? ch (string-ref str b)) (if (= a b)
                (split (+ 1 a) (+ 1 b))
                  (cons (substring str a b) (split b b))))
                (else (split a (+ 1 b)))))))
                  (split 0 0))))

; WriteCSV Function
; Writes a CSV with the contents of 'list-to-be-printed'
; The name of the file is passed as a parameter (fileName)
; Uses call-with-output-file helper function
; Sources: https://www.scheme.com/tspl3/io.html
(define (writeCSV fileName list-to-be-printed)
  (call-with-output-file fileName
  (lambda (p)
    (let f ((ls list-to-be-printed))
      (cond
        ((not (null? ls))
          (begin
            (write (string-join (car ls) " - ") p)
            (newline p)
            (f (cdr ls))))))))
  (display "CSV File has been created in the same directory of this .scm file") ; Display to user that csv has been created
  (newline)
  (newline)
  (cond
     ((not(null? list-to-be-printed)) list-to-be-printed))) ; Returns the list-to-be-printed just so that the user can see the original Match List

; call-with-output-file Function
; helper function for write csv
; Source: https://www.scheme.com/tspl3/io.html
(define call-with-output-file
  (lambda (filename proc)
    (let ((p (open-output-file filename)))
      (let ((v (proc p)))
        (close-output-port p)
        v))))


; ___________________________________________________________________ HELPER FUNCTIONS ___________________________________________________________________________________

; GetIthSubItem Function
; Returns the ith Sub-Item (or Sub-List) of the parent list L
(define (getIthSubItem L i)
  (cond
    ((equal? 1 i) (car L))
    (else (getIthSubItem (cdr L) (- i 1)))
  )
)

; GetSubList Functoon
; Returns the sub list with first element being elem
(define (getSubList elem L)
  (cond
    ((equal? (caar L) elem) (car L))
    (else (getSubList elem (cdr L)))
  )
)

; hasMatch? Function
; Returns true if element elem is present in the match list ML ((e1 s1) (e2 s2) (e3 s3) ... )
(define (hasMatch? elem ML)
  (cond
    ((null? ML) #f)
    ((not (equal? (member elem (car ML)) #f)) #t)
    (else (hasMatch? elem (cdr ML)))
  )
)

; getStudentMatch Function
; Returns the match (e1 s1) that belongs to the student 'student'
(define (getStudentMatch student ML)
  (cond
    ((equal? (cadr (car ML)) student) (car ML))
    (else (getStudentMatch student (cdr ML)))
  )
)

; ReturnRank function
; Returns the position of the element elem found in the list L (from 1 - 10)
(define (returnRank elem L n)
  (cond
    ((equal? elem (car L)) n)
    (else (returnRank elem (cdr L) (+ 1 n)))
  )
)

; Prefers function
; Returns true if opt1 is closer to 1 than opt2
; Otherwise, return false
(define (prefers? opt1 opt2 L)
  (cond
    ((<= (returnRank opt1 L 0) (returnRank opt2 L 0)) #t)
    (else #f)
  )
)

; Subst Function
; Replaces instance of 'old' with value 'new' in list l
; Thank you stack overflow <3 
(define subst
  (lambda (new old l)
    (cond
     ((null? l) (quote ()))
     ((atom? (car l))
      (cond
       ((eq? (car l) old) (cons new
                                (subst new old (cdr l))))
       (else (cons (car l)
                   (subst new old (cdr l))))))
     (else (cons (subst new old (car l))
                 (subst new old (cdr l)))))))

; Returns true if x is an atom
(define (atom? x)
  (and (not (null? x))
       (not (pair? x))))



