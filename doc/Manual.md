# MAdeK Manual

## Data Models

### Primary

#### `MediaEntry`

[TODO]

#### `Collection`

Also known as `Set`.

[TODO]

#### `FilterSet`

[TODO]

#### `Person`

[TODO]

- a generic `Person`
- *can* be linked to (equal to) a [`User`](#user)
- *can* be linked to `MetaDatum` of type `MetaDatumPerson`  (i.e. "Author")

##### Relations

* [`user`](#user), rails-type: `has_one`, effectively enforced by unique constraint on index

#### `User`

- User with account/login

##### Relations

* [`person`](#person), rails-type: `belongs_to`, null: `false`


#### `Group`

[TODO]

- list of `Users`s
- is manually defined by a `User`
- not to be confused with `InstitutionalGroup`

##### Relations

* [`users`](#user), rails-type: `has_many`

##### Notes

* Supertype of [`InstitutionalGroup`](#institutionalgroup), implemented as `STI`-table


### Secondary

#### `InstitutionalGroup`

##### Notes

* Subtype of [`Group`](#group), implemented as STI in the `groups` table

#### Permissions

Almost like [UNIX](https://en.wikipedia.org/wiki/File_system_permissions#Classes).
Notable Differences:

- 'owner' is not a 'Class' (it's more like *root*, for this thing)
- there is no 'execute', but 'fullsize'
- there is no 'write', but distinct 'edit_data' and 'edit_permissions'


##### Owner

- for `MediaEntry`, `MediaSet`, `FilterSet`, there is always exactly 1 **owner**
- has super-permission **"Delete and Change owner"** (Löschen und Verantwortlichkeit übertragen)
- implicitly has all the granular permissions listed below (if applicable)

##### Per-Subject

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

### Special

#### MediaResources

List of `MediaEntry`s and/or `Collection`s and/or `FilterSet`s (polymorphic).

Formerly a "real" Model, now just a convention between [Presenters][] and [Decorators][] (so they only exist in the UI).

---

## Views

aka "Frontend"
aka "the Website"
aka "the Application", since this is how Madek is exposed to the end user.

The following is 1 Chapter per view, with 1 sub-section per action (`index`, `show`, etc for resources and custom ones )

(when in doubt where an URL goes, see [`routes.rb`](http://github.com/zhdk/madek/blob/master/config/routes.rb))


### `/` (application#root)

The "home page" (no sub-sections, obviously).

Non-resourceful.

**Content:**
- Login Form

### `my`

The user's "My Archive" section.

Non-resourceful.

**Content:**
- Latest (sorted by updated_at)
    - MediaEntries
    - Collections
    - FilterSets
- LatestImported (sorted by created_at)
    - MediaEntries
- Favorite
    - MediaEntries
    - Collections
    - FilterSets



---

---

---

## Glossary

A few terms that are used in this document wich may sound general but
have actually a very clear distinct technical meaning, thus they are
defined here for clarity.
**NOT** a dictionary (use Wikipedia).


### Resource

- distinct kind of thing (noun)
- *not* the "R" in "REST", but [REST is all about Resources](https://en.wikipedia.org/wiki/Representational_state_transfer#Software_architecture)
- it's also what ["MVC"](https://en.wikipedia.org/wiki/Model-View-Controller) and ["CRUD"](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) are about:
- most standardized part of the app
    - "resourceful" routes
    - "resourceful" model/view/controllers


### Polymorph

> "Apples and Oranges can not be compared"

A set is *polymorph* if it contains more than one kind of thing.

Try to avoid polymorph sets as much as possible, because great care has to be
taken with them. Normally easy things like sorting tend to get very hard.

Note: There *are* `PolyThings` in the Application and they are called `Poly`
to clearly mark them as such.


[Presenters]: #presenters
[Decorators]: #decorators
