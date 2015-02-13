**Entities** are all things that exist in the App.  
Rails calls them "Models".  
*Some* of the Entities are "Resources".

# Schema/Database Overview

[![Schema.svg](manual/entities/entities_database_schemata/Schema.svg)](manual/entities/entities_database_schemata/Schema.svg)

# Primary

## [MediaEntry][]

- most important [Resource][] in the App
- has 1 [MediaFile][]
    - has 1 [Preview][]
- has [MetaData][]

### Concerns:

- [MetaData][]
- [Permission][]s

## [MediaFile][]

[TODO]

## [Collection][]

Formerly known as `Set`.

- is a [Resource][]
- is a [MediaResource][]
- has a list of [MediaEntries][]
- belongs to `creator`=[User][]

### Concerns:

- [MetaData][]
- [Permission][]s



## [FilterSet][]

A saved `filter`.

- has many [MediaEntries][], **NOT** through "normal" Relations,
  but because they `filter` matches them!

### Concerns:

- [Permission][]s


## [Person][]

- a generic (real-world) `Person` (German: "Juristische Person")
- *can* be linked to (equal to) a [`User`](#user)
- *can* be linked to `MetaDatum` of type `MetaDatumPerson`  (i.e. "Author")

### Relations

* [`user`](#user), rails-type: `has_one`, effectively enforced by unique constraint on index


## [User][]

- User with account/login

### Relations

* [`person`](#person), rails-type: `belongs_to`, null: `false`


## [Group][]

- list of [Users][]s
- is manually defined by a [Users][]
- not to be confused with [InstitutionalGroup][]

### Relations

* `users`: list of [Users][]s, rails-type: `has_many`

### Notes

* Supertype of [`InstitutionalGroup`](#institutionalgroup), implemented as `STI`-table


# Secondary

## [InstitutionalGroup][]

An externally-defined Group, synced with an `LDAP`-Directory.

- has a list of [User][]s ("Members"),
  which by definition must have User-ID from the same Directory.

### Notes

* Subtype of [`Group`](#group), implemented as STI in the `groups` table

# Concerns

Entities that have similar Relations to several [Resources][]s
are called Concerns.

## [Permission][]s

Almost like [UNIX](https://en.wikipedia.org/wiki/File_system_permissions#Classes).
Notable Differences:

- 'owner' is not a 'Class' (it's more like *root*, for this thing)
- there is no 'execute', but 'fullsize'
- there is no 'write', but distinct 'edit_data' and 'edit_permissions'


### [Owner][]

- for `MediaEntry`, `MediaSet`, `FilterSet`, there is always exactly 1 **owner**
- has super-permission **"Delete and Change owner"** (Löschen und Verantwortlichkeit übertragen)
- implicitly has all the granular permissions listed below (if applicable)

### Per-Subject

More granular permissions can be granted
**on** `MediaEntry`s, `MediaSet`s and `FilterSet`s,
**for** `User`s, `Group`s, `APIClient`s, as well as *"public"*.

"public" permissions apply to any request, logged in or not.


| subject/permission | data_and_preview            | edit_data                                        | fullsize                                 | edit_permissions              |
| :----------------  | :-------------------------: | :-------------:                                  | :-------------:                          | :----------------:            |
| **`MediaEntry`**   | get metadata and previews   | edit metadata                                    | get full size                            | edit permissions              |
| ↳ `User`           | ✔                           | ✔                                                | ✔                                        | ✔                             |
| ↳ `Group`          | ✔                           | ✔                                                | ✔                                        | -                             |
| ↳ `APIClient`      | ✔                           | -                                                | ✔                                        | -                             |
| ↳ "public"         | ✔                           | -                                                | ✔                                        | -                             |
| *Beschreibung*     | betrachten                  | Metadaten editieren                              | Original exportieren und in PDF blättern | Zugriffsberechtigungen ändern |
|                    |                             |                                                  |                                          |                               |
|                    |                             |                                                  |                                          |                               |
| **`MediaSet`**     | get metadata and previews   | edit metadata **and relations**                  | -                                        | edit permissions              |
| ↳ `User`           | ✔                           | ✔                                                | -                                        | ✔                             |
| ↳ `Group`          | ✔                           | ✔                                                | -                                        | -                             |
| ↳ `APIClient`      | ✔                           | ✔                                                | -                                        | -                             |
| ↳ "public"         | ✔                           | -                                                | -                                        | -                             |
| *Beschreibung*     | betrachten                  | Metadaten editieren & Inhalte hinzufügen         | -                                        | Zugriffsberechtigungen ändern |
|                    |                             |                                                  |                                          |                               |
|                    |                             |                                                  |                                          |                               |
| **`FilterSet`**    | get metadata and previews   | edit metadata **and filter**                     | -                                        | edit permissions              |
| ↳ `User`           | ✔                           | ✔                                                | -                                        | ✔                             |
| ↳ `Group`          | ✔                           | -                                                | -                                        | -                             |
| ↳ `APIClient`      | ✔                           | ✔                                                | -                                        | -                             |
| ↳ "public"         | ✔                           | -                                                | -                                        | -                             |
| *Beschreibung*     | betrachten                  | Metadaten editieren & Filtereinstellungen ändern | -                                        | Zugriffsberechtigungen ändern |

## [Copyright][]

*This is a generic description which applies to all countries which have
signed and implemented the ??? Copyright Treaty.*  
*This is **not** about trade- and other marks nor about patents.*

Every "Creative Work" (encoded by a [MediaFile][])
can have one or more authors in a legal sense

**IF** the the Work falls into the **public domain**,
none of the following is relevant!  
There MAY still be authors in an historic/cultural/moral/ sense but as far as
copyright law (and this "algorithm") is concerned, the "public" now "owns" all
the rights, similar to Air.  
Conditions for the public domain also differ by country, but generally

- all authors are dead for more than 70-90 years
- the work has been published for more than 70-90 years
- if the author(s) relinquished his rights by declaring the work to be
  in the public domain and it was created in a country that allows this
  (for example the USA, but not Germany).

Any of those authors has *"the right to copyrights"*
**IF** the "creative contribution" was significant

      - which is defined per kind of media…, e.g.
          - Photos always apply if made by human!
          - Fonts not "different" enough from just Alphabet "Letters"
          - Music, Film, etc: "I know it when I see it"

This decision can *NOT* be made programmatically, we have to rely
on the user to correctly tell us the `copyrighted` status, which can be true
or false (when it's in the public domain) or `null` if unknown.

There are actually several distinct rights the author(s) has by law,
the German term "Urheberrechte" is more clear in this sense:

- "commercial rights", aka "what the term *copy*-right means"
    - publishing (to the public)
    - copying
    - distributing copies (to the public)
- "moral rights"
    - being named as the author
    - not having the work destroyed/defaced
    - visiting the work (some countries)
    - get payed a share if the work is sold for profit (some countries)
- several more…

The only two to "transfer the right of executing" any of the "copyright rights"
is by **LAW** or in form of a **LICENSE**. A License **MUST** specify

- the (list of) WORKs
- the list RIGHTS being licensed
- to WHOM
- WHERE
- WHEN
- under which CONDITIONS
- BOOL: exclusive or not
- BOOL: can be sub-licensed

A **LAW** usually specifies the same properties.
While it's not a License in the legal sense, both can be technically
handled in the same way: a thing that transfers rights to a work to one more
entities, with the above properties.

A **LICENSE** also has a SOURCE property, which is either

- a specific LAW, or
- a specific contract between the author(s) and one more third parties
- a License "for the public", published with the work (Free Software, CreativeCommons)


Which RIGHTS can be licensed also depends on the country:
The commercial right can always be licensed, but many countries restrict
licensing of some moral rights ('like being named').

Note: Reading this list it becomes clear that simple copyleft licenses
like BSD, MIT or WTFPL define almost the absolute minimum of a valid license.

There is 1 Swiss **LAW** that is very important in the context of Madek
(actually a chain of several laws up to the federal level…):  
For all Works created at the ZHdK by employees (as part of their work)
or students (as part of their studies), the commercial rights are transferred
to the ZHdK (this applies to all almost all Universities).

The ZHdK bylaws state about these rights

- they can be used by the university in any way
- the creator can negotiate terms for own usage by case
- conditions of usage for third parties
    - e.g. publishing for PR, caption must include "(c) ZHdK, Name of Creator"
- "sub-licensed" on a department-level, they can alter conditions
    - e.g. caption must include "(c) Department Design ZHdK, Name of Creator"
    - a department *could* also put all students works under CC-BY-NC-SA


TL;DR:
There is no Model "Copyright", but a 'copyrighted' attribute on MediaFiles.
A Model "License" would be enough to represent all the ways to transfer rights.

For the User, the UI could stay roughly the same but allow more options.
There can be some specific hints if we know about the context from Metadata
about the File or the User (e.g. Link to the official University explanation
about the above situation when the User is a student or employee).

The current schema could be migrated from the MetaData, but would require
manual intervention because right now the field 'Copyright' is just a string,
and has no consistent usage.
It is mostly used like `if (copyrighted==true) then creator.name else 'Public Domain'`,
but for the ZHdK-Works mentioned above it is often:
`if (license.where(source: 'special-zhdk-rules') then 'ZHdK' else creator.name`.
(Option: leave the old field, but don't allow it to be used for new entries (deprecation))


# Special

## [MediaResource][]

Either a [MediaEntry][] or a [Collection][] or a [FilterSet] (polymorphic).

Formerly a "real" Model, now just a convention between
[Presenter][]s and [Decorator][]s (so they only exist in the UI).


---

---

## Glossary

A few terms that are used in this document wich may sound general but
have actually a very clear distinct technical meaning, thus they are
defined here for clarity.
**NOT** a dictionary (use Wikipedia).


### [Resource][]

- distinct kind of thing (noun)
- *not* the "R" in "REST", but [REST is all about Resources](https://en.wikipedia.org/wiki/Representational_state_transfer#Software_architecture)
- it's also what ["MVC"](https://en.wikipedia.org/wiki/Model-View-Controller) and ["CRUD"](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) are about:
- most standardized part of the app
    - "resourceful" routes
    - "resourceful" model/view/controllers


### [Polymorph][]

> "Apples and Oranges can not be compared"

A set is *polymorph* if it contains more than one kind of thing.

Try to avoid polymorph sets as much as possible, because great care has to be
taken with them. Normally easy things like sorting tend to get very hard.

Note: There *are* `PolyThings` in the Application and they are called `Poly`
to clearly mark them as such.


[Collection]: #Collection
[Concern]: #Concern
[Decorator]: ../development/ui-framework/#decorators
[FilterSet]: #FilterSet
[Group]: #Group
[InstitutionalGroup]: #InstitutionalGroup
[MediaEntries]: #MediaEntry
[MediaEntry]: #MediaEntry
[MediaFile]: #MediaFile
[MediaResource]: #MediaResource
[People]: #Person
[Permission]: #Permission
[Person]: #Person
[polymorph]: #Polymorph
[Presenter]: ../development/ui-framework/#presenters
[Preview]: #Preview
[Resource]: #Resource
[User]: #User
