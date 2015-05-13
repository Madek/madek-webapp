This is a collection of small tips and guides that don't fit anywhere else.
Use it as a 'staging' area to quickly write down stuff.
It should be regularly checked if sections from here should go e.g. to the Manual.


# Ajax: use callbacks

```js
$.ajax({ success: fn, error: fn });
```

<iframe src="//giphy.com/embed/yoJC2w7g94RPFYc0mI" width="480" height="313" frameBorder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>


# Images/Thumbnails

We currently have the following image sizes (aka thumbnails):

| Name        | Size  (longest Side) |
|-------------|----------------------|
| `small`     | 100                  |
| `small_125` | 125                  |
| `medium`    | 300                  |
| `large`     | 500                  |
| `x_large`   | 768                  |
| `maximum`   | (original)           |


# Routes

- Generate a condensed routing table with following command:

    DOC='doc/Routes.md' && echo '|Name|Method|Route|Controller|' > $DOC && echo '|---|---|---|---|' >> $DOC && rake routes | tail -n +2 | grep 'GET' | grep -v 'app_admin' | sed -E 's/[ ]+/|/g' | sed -E 's/$/ |/' | sed -E 's/^\|GET/| |GET/' >> $DOC


# Rails

# Hooks

TODO: @DrTom (just a very general guideline)

- when to use hooks, when not to
- more importantly: what to never do in certain hooks!
- point to good examples in repo


# v2: Frontend

## `jQuery.fixed-table-headers`

- it is a [magic plugin](http://fixedheadertable.com) that takes care of fixed
  headers on tables
- it only works correctly if the table is actually visible
- our js never inits a (somehow) hidden table, so:
- if we ever `.show()` the table (or parent),
  **we need to initialize it ourselves!**
    - reason: `jQuery` does not have an `.on('show')` event we could hook into
    - for convenience, the correct function call is attached to the DOM element,
      use it like this:  
      ````js
      // find the table
      var thetable = $('.laterTableInit');
      // call attached function with el as arg
      thetable.get(0)._initTable(thetable);
      ````

## PDF Display

There are two ways PDFs are shown inside Madek's HTML:

1. Converted to and embedded as JPG file ("preview", "thumbnail")
2. Embedded as PDF, displayed using `pdf.js` ("document")

Note that there are the usual (per-Entry) **Permissions** at play here,
but they might be confusing:
A User with the *"view"* Permission can only see the
JPG version. **To display the PDF itself the *"download original"* Permission is
needed!**

## `pdf.js`

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

### Upgrading

- currently used version is years behind
- mayor improvements since then (performance, stability)
- also mayor API changes
- might be faster to almost start from scratch

#### Recommended Workflow:

- read the [overview](https://mozilla.github.io/pdf.js/getting_started/)
- get the `#document` to work
- read [API docs and or source](https://mozilla.github.io/pdf.js/api/)
- port over custom controls in `#show`

#### Hints

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


### etc

- `#show`: better UX before pdf has loaded
    - grey background, display `.ui-preloader`
    - if pdf height/width-ratio is known, apply it to the preview area
