Madek Submit and Review Process Documentation
=============================================

This document describes the process for submitting commits, reviewing them, and
finally merging them. 

Scope 
-----

The scope of the process described in this document comprises all submit
requests and contracted work which results in one or more commits to be merged
to the Madek project. 

There is a relaxed process for work performed within the core Madek-Team. 

Branches 
--------

The `master` branch in Madek contains only stable releases. The main working
branch is called `next`. In addition there is currently a branch called
`madek-v3` used for the refactoring phase.

Submitting
----------

An entity of work can be either submitted via a ticket on pivotal or by a pull
request on github. It must adhere to the following rules. 

1. All changes must be contained in one single commit.

2. This single commit must be directly related to the current working
  branch (either `next` oder `madek-v3`). 

3. The submit comment must contain the three following:

    1. a link pointing to the related test run on ci2.zhdk.ch,
    2. a link pointing to the coverage result on ci2.zhdk.ch, and
    3. a link pointing to the corresponding code analytics on code climate. 


Reviewing 
---------

A submitted entity of work must be reviewed by the architect
(Thomas.Schank@zhdk.ch) or by a person designated by the architect. In the case
of a work related to a ticket on privotal the ticked might specify the
designated reviewer in advance. 

The review must conclude with a summary comment on the pivotal ticket or the
github commit. This comment must contain information if the request is accepted
or rejected.


Merging
-------

If the summited work is accepted the reviewer must merge the work in a single
commit on top to the current working branch. The author of the commit must
refer to the original author who submitted the work and the committer must
refer to the person who reviewed and merged the commit. 


Relaxed Process for the Madek Core-Team
---------------------------------------

This section describes a relaxed process applicable to the core Madek-Team.
This process is applied the end of avoiding exzessive effort during development
and in particular with respect of merging commits. Developers will commit
a unit of work them self and immediately when the work is finished. Reviews
will be added afterwards.

People belonging to the core Madek-Team: 

  * Matus Kmit <matus.kmit@zhdk.ch>
  * Max F. Albrecht <max.albrecht@zhdk.ch>
  * Thomas Schank <thomas.schank@zhdk.ch>

