#lang racket/base

(require rackunit wxme)

(check-equal? (string->lib-path "(lib \"main.rkt\" \"unknown-library\")" #t)
              '(lib "main.rkt" "unknown-library"))
(check-equal? (string->lib-path "(lib \"main.rkt\" \"unknown-library\")" #f) #f)
(check-equal? (string->lib-path "drscheme:number" #f) '(lib "number.ss" "wxme"))
(check-equal? (string->lib-path "drscheme:number" #t) #f)
(check-equal? (string->lib-path "no parens" #f) #f)
(check-equal? (string->lib-path "no parens" #t) #f)
(check-equal? (string->lib-path "(parens but bogus internals)" #f) #f)
(check-equal? (string->lib-path "(parens but bogus internals)" #t) #f)
