#lang racket/base
(require wxme
         wxme/image
         racket/snip
         rackunit
         racket/class)

(define snips
  (call-with-input-file
   (collection-file-path "image.wxme" "wxme/test")
   (λ (in)
     (define wxme-in (wxme-port->port in))
     (list (read wxme-in)
           (read wxme-in)))))

(check-equal? #t (andmap (lambda (i) (i . is-a? . image%)) snips))
(check-equal? #t (andmap (lambda (i) (i . is-a? . image-snip%)) snips))
(check-equal? '(1.0 2.0) (map (lambda (i) (send (send i get-bitmap) get-backing-scale)) snips))
