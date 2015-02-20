Madek Admin-Interface Development Guide
=======================================

This documents describes principles for developing the new admin-interface of
Madek version 3. It expands on the [Development Guide for Madek Version 3][].


Basics
------

The admin-interface of Madek version 2 was developed with focus on speed and
providing solutions quickly. We focus more one quality and stability for the
admin-interface of Madek version 3. This includes visual appearance and user
experience.


Principles
---------

The [Development Guide for Madek Version 3][] introduces the [Resource-oriented
Client Architecture][] style. The admin-interface of Madek version 3 adheres to
this principle in general. There are no exceptions.



Specific Aspects
-----------------

* The base URL of the new admin-interface is `/admin/`.
* Links never open new tabs (yet windows) by default.


  [Development Guide for Madek Version 3]: ./developer_rules.md
  [Resource-oriented Client Architecture]: http://roca-style.org/
