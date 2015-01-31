**Models**, aka Entities, aka Resources.

# Primary

## `MediaEntry`

[TODO]

## `Collection`

Also known as `Set`.

[TODO]

## `FilterSet`

[TODO]

## `Person`

[TODO]

- a generic `Person`
- *can* be linked to (equal to) a [`User`](#user)
- *can* be linked to `MetaDatum` of type `MetaDatumPerson`  (i.e. "Author")

### Relations

* [`user`](#user), rails-type: `has_one`, effectively enforced by unique constraint on index

## `User`

- User with account/login

### Relations

* [`person`](#person), rails-type: `belongs_to`, null: `false`


## `Group`

[TODO]

- list of `Users`s
- is manually defined by a `User`
- not to be confused with `InstitutionalGroup`

### Relations

* [`users`](#user), rails-type: `has_many`

### Notes

* Supertype of [`InstitutionalGroup`](#institutionalgroup), implemented as `STI`-table


# Secondary

## `InstitutionalGroup`

### Notes

* Subtype of [`Group`](#group), implemented as STI in the `groups` table

## Permissions

Almost like [UNIX](https://en.wikipedia.org/wiki/File_system_permissions#Classes).
Notable Differences:

- 'owner' is not a 'Class' (it's more like *root*, for this thing)
- there is no 'execute', but 'fullsize'
- there is no 'write', but distinct 'edit_data' and 'edit_permissions'


### Owner

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

# Special

## MediaResources

List of `MediaEntry`s and/or `Collection`s and/or `FilterSet`s (polymorphic).

Formerly a "real" Model, now just a convention between [Presenters][] and [Decorators][] (so they only exist in the UI).
