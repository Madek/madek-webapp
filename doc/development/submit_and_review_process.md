Madek Submit and Review Process Documentation
=============================================

This document describes the process for submitting commits, reviewing them, and
finally merging them. 

Scope 
-----

The scope of the process described in this document comprises all submit
requests and contracted work which results in one or more commits to be merged
to the Madek project. 

There is a relaxed process for work within the core development team. 

Branches 
--------

The `master` branch in Madek contains only stable releases. The main working
branch is called `next`. In addition there is currently a branch called
`madek-v3` used for the refactoring phase.

Submitting
----------

An entity of work muste be submitted via a a pull request on github. 
If it is connected to a ticket on pivotal, it's number has to be included.

It must adhere to the following rules. 

1. All changes must be contained in one single commit.  
   If work on the branch is done over a long time, single commits can be submitted
   for review by starting the title of the pull request with `[WIP]`.

2. The commits must be directly related to the current working
  branch (either `next` oder `madek-v3`), 
  i.e. "the merge button has to be green".

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
squashed commit on top to the current working branch. The author of the commit must
refer to the original author who submitted the work and the committer must
refer to the person(s) who reviewed and merged the commit with one or more 
`Signed-off-by: Name <email>` Tags as the last lines of the commit message.



Relaxed Process for the Madek Core-Team
---------------------------------------

This section describes a relaxed process applicable to the core Madek-Team to
the end of avoiding exzessive effort during development and in particular with
respect of merging commits. Developers will commit a unit of work them self and
immediately when the work is finished. Reviews will be added afterwards. 
To explicitly state this, these commits should include a `Signed-off-by` with 
their own name.
