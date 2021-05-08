#lang racket
(require racket/gui/base
         wxme
         rackunit)

(module+ test (run-tests))

(define (run-tests)
  (check-equal? (let ([t (new text%)])
                  (send t insert "abc")
                  (save-and-read t))
                'abc)

  (check-equal? (let ([t (new text%)])
                  (send t insert "123")
                  (save-and-read t))
                123)

  (let ()
    (define bmp (make-bitmap 10 10))
    (define bdc (make-object bitmap-dc% bmp))
    (send bdc draw-ellipse 1 1 8 8)
    (send bdc set-bitmap #f)

    (check-equal? (let ([t (new text%)])
                    (send t insert (make-object image-snip% bmp))
                    (all-bmp->bytes (save-and-read t)))
                  (bmp->bytes bmp)))

  (let ()
    (define bmp (make-bitmap 10 10))
    (define bdc (make-object bitmap-dc% bmp))
    (send bdc draw-ellipse 1 1 8 8)
    (send bdc set-bitmap #f)

    (check-equal? (let ([t (new text%)])
                    (send t insert (make-object image-snip% bmp))
                    (send t insert (make-object image-snip% bmp))
                    (all-bmp->bytes (save-and-read t)))
                  (list 'begin
                        (bmp->bytes bmp)
                        (bmp->bytes bmp))))

  (let ()
    (define bmp (make-bitmap 100 100))
    (define bdc (make-object bitmap-dc% bmp))
    (send bdc draw-ellipse 10 10 80 80)
    (send bdc set-bitmap #f)

    (check-equal? (let ([t (new text%)])
                    (send t insert (make-object image-snip% bmp))
                    (bmp->bytes (send (save-and-read t) get-bitmap)))
                  (bmp->bytes bmp)))

  (let ()
    (define bmp (make-bitmap 100 100))
    (define bdc (make-object bitmap-dc% bmp))
    (send bdc draw-ellipse 10 10 80 80)
    (send bdc set-bitmap #f)

    (check-equal? (let ([t (new text%)])
                    (send t insert (make-object image-snip% bmp))
                    (send t insert (make-object image-snip% bmp))
                    (all-bmp->bytes (save-and-read t)))
                  (list 'begin
                        (bmp->bytes bmp)
                        (bmp->bytes bmp))))


  (let ()
    (define t (new text%))
    (send t insert "\"abc\"")
    (define bp (open-output-bytes))
    (send t save-port bp)
    (define wx-port (wxme-port->port (open-input-bytes (get-output-bytes bp))))
    (define tx-port (open-input-text-editor t))
    (check-equal? (read wx-port) "abc"))

  (let ()
    (define t (new text%))
    (send t insert "123")
    (define bp (open-output-bytes))
    (send t save-port bp)
    (define wx-port (wxme-port->port (open-input-bytes (get-output-bytes bp))))
    (check-equal? (read wx-port) 123))
  

  (let ()
    (define bmp (make-bitmap 100 100))
    (define bdc (make-object bitmap-dc% bmp))
    (send bdc draw-ellipse 10 10 80 80)
    (send bdc set-bitmap #f)
    (define t (new text%))
    (define i1 (make-object image-snip% bmp))
    (define i2 (make-object image-snip% bmp))
    (send t insert i1)
    (send t insert i2)
    (define bp (open-output-bytes))
    (send t save-port bp)
    (define wx-port (wxme-port->port (open-input-bytes (get-output-bytes bp))))
    (check-equal? (read wx-port) i1)
    (check-equal? (read wx-port) i2))

  (let ()
    (define bmp1 (make-bitmap 100 100))
    (define bmp2 (make-bitmap 100 100))
    (define bdc (make-object bitmap-dc% bmp1))
    (send bdc draw-ellipse 10 10 80 80)
    (send bdc set-bitmap bmp2)
    (send bdc draw-ellipse 20 10 80 40)
    (send bdc set-bitmap #f)
    (define t (new text%))
    (define i1 (make-object image-snip% bmp1))
    (define i2 (make-object image-snip% bmp2))
    (send t insert i1)
    (send t insert i2)
    (define bp (open-output-bytes))
    (send t save-port bp)
    (define wx-port (wxme-port->port (open-input-bytes (get-output-bytes bp))))
    (check-equal? (read wx-port) i1)
    (check-equal? (read wx-port) i2)))

(define (save-and-read t)
  (define bp (open-output-bytes))
  (send t save-port bp)
  (wxme-read (open-input-bytes (get-output-bytes bp))))

(define (all-bmp->bytes x)
  (let loop ([x x])
    (cond
      [(pair? x) (cons (loop (car x))
                       (loop (cdr x)))]
      [(is-a? x image-snip%) (bmp->bytes (send x get-bitmap))]
      [else x])))

(define (bmp->bytes bmp)
  (define w (send bmp get-width))
  (define h (send bmp get-height))
  (define bytes (make-bytes (* w h 4)))
  (send bmp get-argb-pixels 0 0 w h bytes)
  bytes)
