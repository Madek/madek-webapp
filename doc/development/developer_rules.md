Development Guide for Madek Version 3
=====================================

This documents describes principles for developing Madek version 3.


Basics
---------

A large part of Madek version 2 was created with the mind of providing the
snappiest user interface with no much regard towards maintainability and
stability. The development of Madek version 3 focuses on simplicity, stability
and maintainability. 


Principles
----------

### Progressive Enhancement and Resource-oriented Client Architecture

We strife to follow the recommendations of the [Resource-oriented Client
Architecture][] style and progressive enhancement. More precisely, all the
major views must use this style.  

Some parts, batch edit for example, may violate this principle and may rely
entirely on JavaScript to function. We open this possibility to the end of not
degrading user experience. Additionally we want to enable a streamlined
development where progressive enhancement would effectively result in more
complex and costly solutions. 

The resources violating ROCA style shall be coordinated with the architect and
recorded in this document. 





### Architecture and code quality 

We do not excessively specify rules to ensure quality respectively architecture
and code. We rely on a review process, see the [Madek Submit and Review Process
Documentation][].

We use some tools which complement the manual review process. There is a static
code format analyzer. It will fail upon violation. Any changes of the
configuration of this tool must be coordinated with the architect, respectively
brought up in team meetings. Further static code analysis is done via an
external service. This is documented in the [Madek Submit and Review Process
Documentation][].


  [Madek Submit and Review Process Documentation]: ./submit_and_review_process.md
  [Resource-oriented Client Architecture]: http://roca-style.org/
