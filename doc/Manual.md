# MAdeK Manual

## Data Models

### Primary

#### `MediaEntry`

[TODO]

#### `MediaSet`

[TODO]

#### `FilterSet`

[TODO]

#### Person

[TODO]

- a generic Person
- *can* be linked to a [`User`](#user)

#### `User`

- User with account/login
- *can* be linked to a `Person`

#### `Group`

[TODO]

- list of `Users`s
- is manually defined by a `User`
- not to be confused with `InstitutionalGroup`

### Secondary

#### Permissions

##### Owner

- for `MediaEntry`, `MediaSet`, `FilterSet`, there is always exactly 1 **owner**
- has super-permission **"Delete and Change owner"** (Löschen und Verantwortlichkeit übertragen)
- implicitly has all the granular permissions listed below (if applicable)

##### Per-Subject

More granular permissions can be granted 
**on** `MediaEntry`s, `MediaSet`s and `FilterSet`s,
**for** `User`s, `Group`s, `APIClient`s, as well as *"public"*.

"public" permissions apply to any request, logged in or not.


|subject/permission| data_and_preview          |  edit_data    |  fullsize     | edit_permissions |
|:---------------- |:-------------------------:|:-------------:|:-------------:|:----------------:|
| **`MediaEntry`** | get metadata and previews | edit metadata | get full size | edit permissions |
| ↳ `User`        |   ✔                       |   ✔           |   ✔           |   ✔             |
| ↳ `Group`       |   ✔                       |   ✔           |   ✔           |   -             |
| ↳ `APIClient`   |   ✔                       |   -           |   ✔           |   -              |
| ↳ "public"      |   ✔                       |   -           |   ✔           |   -              |
| *Beschreibung*   | betrachten | Metadaten editieren | Original exportieren und in PDF blättern | Zugriffsberechtigungen ändern |
| | | | | |
| | | | | |
| **`MediaSet`**   | get metadata and previews | edit metadata **and relations** | - | edit permissions |
| ↳ `User`        |   ✔                       |   ✔           |   -           |   ✔              |
| ↳ `Group`       |   ✔                       |   ✔           |   -           |   -              |
| ↳ `APIClient`   |   ✔                       |   ✔           |   -           |   -              |
| ↳ "public"      |   ✔                       |   ✔           |   -           |   -              |
| *Beschreibung*   | betrachten | Metadaten editieren & Inhalte hinzufügen| - | Zugriffsberechtigungen ändern |
| | | | | |
| | | | | |
| **`FilterSet`**   | get metadata and previews | edit metadata **and filter** | - | edit permissions |
| ↳ `User`        |   ✔                       |   ✔           |   -           |   ✔              |
| ↳ `Group`       |   ✔                       |   ✔           |   -           |   -              |
| ↳ `APIClient`   |   ✔                       |   ✔           |   -           |   -              |
| ↳ "public"      |   ✔                       |   ✔           |   -           |   -              |
| *Beschreibung*   | betrachten | Metadaten editieren & Filtereinstellungen ändern | - | Zugriffsberechtigungen ändern |

