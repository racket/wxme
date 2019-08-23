#lang info

(define collection 'multi)

(define deps '("rackunit"
               "wxme-lib"
               "base"
               ["gui-lib" #:version "1.41"]
               "snip-lib"))

(define pkg-desc "tests for \"wxme\"")

(define pkg-authors '(mflatt))
