# Developer Guide

This is a *work in progress*.
It is **far from complete**, content is added as needed.


## Data Modell

### (Individual) Contexts

* All metadata in MAdeK is contained in "contexts"
* Some are built-in ("Core", etc), some are defined by (admin) user
* Contexts that are user-defined are called **"Individual Contexts"**
    * In the UI, they are always called "Vocabulary" (in German "Vokabular")!
* **"Individual Contexts"** form a **Vocabulary**, consisting of **Keys** (i.e. "color") and **Terms** (i.e. "green")

#### Assignment

* **"Individual Contexts" (IC)** can be ***assigned to*** and ***activated on*** (Media-)`Sets`
* The assignment is inherited to it's Children `Set`s, from the *inital `Set`* down
* An assigned `Set` can be *activated* and *deactivated* for these child Sets (by User)

#### Implementaion

aka "tricky consequences of this system that we have to take care of"

* When an IC is assigned to a `Set`, it should be *activated* for all the Children!
* ??? — When a `Set` is no longer Child of an *initial Set*, it should retain the IC (by assigning it directly)


#### Queries

(These exist all over the place right now, cleaning that up is TBD)

* `media_set.contexts`: List of all ICs *assigned* to the `Set`
    * `context.inherited`: True if the `Set` has inherited the IC (it is not the *initial Set*)
    * `context.active`: True if the IC is *activated* for the `Set` (can only be true and is only relevant if `inherited` is also true)

* `context.media_entries`: all `MediaResources` which are contained in a Set (or it's children) for which the IC is *active*
    * `.count`: count of these `Resources`

* `context.vocabulary`: List of the `key`s in a context, containg each a list of `term`s
    * `key.alphabetical_order`: True if the `term`s in this `key` are sorted alphabetically (as opposed to manually)
    * `term.usage_count`: how many of the `context.media_entries` are using this term?
    * `.totalcount`: Highest `term.usage_count` for this `context`


## Media Files

### Images

We currently have the following image sizes (aka thumbails):

| Name        | Size  (longest Side) |
|-------------|----------------------|
| `small`     | 100                  |
| `small_125` | 125                  |
| `medium`    | 300                  |
| `large`     | 500                  |
| `x_large`   | 768                  |
| `maximum`   | (original)           |


## Routes

- Generate a condensed routing table with following command:

    DOC='doc/Routes.md' && echo '|Name|Method|Route|Controller|' > $DOC && echo '|---|---|---|---|' >> $DOC && rake routes | tail -n +2 | grep 'GET' | grep -v 'app_admin' | sed -E 's/[ ]+/|/g' | sed -E 's/$/ |/' | sed -E 's/^\|GET/| |GET/' >> $DOC


## Rails

### Error Handling

TODO: module

If something goes wrong in a controller (or view?),
we `raise` the appropriate error class.

All error classes are defined in `ApplicationController`.
For convenience, the classes and their names are
based on HTTP error codes (4xx/5xx).
Look there for the complete list with some explanations.


### Hooks

TODO: @DrTom (just a very general guideline)

- when to use hooks, when not to
- more importantly: what to never do in certain hooks!
- point to good examples in repo


## Frontend

### `jQuery.fixed-table-headers`

- it is a [magic plugin](http://fixedheadertable.com) that takes care of fixed
  headers on tables
- it only works correctly if the table is actually visible
- our js never inits a (somehow) hidden table, so:
- if we ever `.show()` the table (or parent),
  **we need to initialize it ourselves!**
    - reason: `jQuery` does not have an `.on('show')` event we could hook into
    - for convienice, the correct function call is attached to the DOM element,
      use it like this:  
      ````js
      // find the table
      var thetable = $('.laterTableInit');
      // call attached function with el as arg
      thetable.get(0)._initTable(thetable);
      ````

### PDF Display

There are two ways PDFs are shown inside madek's HTML:

1. Converted to and embedded as JPG file ("preview", "thumbnail")
2. Embedded as PDF, displayed using `pdf.js` ("document")

Note that there are the usual (per-Entry) **Permissions** at play here,
but they might be confusing:
A User with the *"view"* Permission can only see the
JPG version. **To display the PDF itself the *"download original"* Permission is
needed!**

### `pdf.js`

To display PDFs, [Mozilla's `pdf.js` library](https://mozilla.github.io/pdf.js/)
is used.

There are two places in the UI where PDFs are embedded, with some notable
differences.

- `MediaEntry#show` - `pdf.js/view` is embedded just as an image would be
    * no visible UI from `pdf.js`
    * custom control elements: page nav, "zoom" (opens `#document`)

- `MediaEntry#document` - only the `pdf.js/view` is loaded
    * full pdf.js "Viewer" including UI (toolbars, etc.)

In both cases, an `access_hash` is added to the query in order to provide
authenticated access to the raw file.

#### Upgrading

- currently used version is years behind
- mayor improvements since then (performance, stability)
- also mayor API changes
- might be faster to almost start from scratch

##### Recommended Workflow:

- read the [overview](https://mozilla.github.io/pdf.js/getting_started/)
- get the `#document` to work
- read [API docs and or source](https://mozilla.github.io/pdf.js/api/)
- port over custom controls in `#show`

##### Hints

- the architecture of the library has changed, as laid out in their overview
    - for `#show`, embed the `Display` and use it's API.
    - for `#document`, embed the complete `Viewer`
    - this is mostly abstracted away anyhow in the existing js/coffee,
      so the views shouldn't change to much.
- When including `js` and `css`, use the (new) pre-built versions.
  This affects (at least) the following sources:
    - `app/assets/javascripts/pdf.js.erb`
    - `app/assets/stylesheets/pdf-viewer.sass`
    - `app/views/media_entries/document.html.haml`
    - `app/views/media_entries/previews/document/_full_document.html.haml`


#### etc

- `#show`: better UX before pdf has loaded
    - grey background, display `.ui-preloader`
    - if pdf height/width-ratio is known, apply it to the preview area


----

## UI Components

From small to bigger

1. plain HAML - HTML tags and content. only very simple things.
2. partials - combos, no nesting, supports config and data
3. ui helpers - combos, nestable, supports config and block(s)
    - how to build something like `FormBuilder`?
      ```
      = ui_sidenav(config) do |nav|
        nav.item do
          %a.foobar

      ```
    - some links regarding this syntax/api:
        - "Rails Builders" - formbuilder, jbuilder, xmlbuilder, …
        - [rails' `form_helper.rb`](https://github.com/rails/rails/blob/f9d4b50944e09273e299ff1b3cec5638320b7ae9/actionview/lib/action_view/helpers/form_helper.rb)
        - [`multiblock` gem](https://github.com/monterail/multiblock)
        - [`rails-multi_block_helpers` gem](https://github.com/Selleo/rails-multi_block_helpers)
        - [haml blocks and capture](https://www.ruby-forum.com/topic/2174513)
        - [manual haml engine](http://stackoverflow.com/questions/9623020/rendering-haml-from-rails-helper-inside-a-loop-iteration?rq=1)
    - more interesting ideas:
        - [`haml_user_tags` gem](http://cgamesplay.github.io/haml_user_tags/tutorial.html)
4. Rails Layouts => rails views, clear definition of sections

### Why?

- implement each element only once: less room for errors, total consistency
    - no arbitrary nesting of CSS classes (which might work or not)
    - identical DOM structure everywhere, less JavaScript bug
    - easier refactoring of CSS architecture later on


### Rules

- all layouts inherit from _base, no further sub-layouts (get to messy)
- no `@variables` outside of top-level views (directly called from controller)


### Styleguide TODO

- info-only-section should contain 1 markdown doc instead of 1 haml doc
- <http://pathfindersoftware.com/2008/07/pretty-blocks-in-rails-views/>
