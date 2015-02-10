# UI Framework

[WIP]

Design part and nomenclature kind of inspired by: [Brad Frost's "Atomic Web Design"](http://bradfrost.com/blog/p/atomic-web-design/),
so it might be helpful to read it.


### UI Elements (very short API overview)

These are all just Rails View partials called with some helpers to prepare the data.

#### "Atoms":
- are just HTML nodes w/ CSS styles, not partials, just HAML

#### Components:
- `component(name, config = {}, &block)`
- Basic visual "Molecules".

#### Combos:
- `combo(name, config = {}, &block)`
- "Organisms" composed of several Components.

#### Decorators:
- `deco(name, config = {})`
- partials for specific presenters, which they receive via the @get var.

#### Layouts:
- are in `views/layout`, 'helpers' already built into rails
- "API": use `content_for` to fill different parts of the layout. If important content is missed, a warning is logged.


## Resourceful Rendering Walkthrough

*(Roughly complete steps, the more details the more custom it is)*

1. **User** *(Any)*  
opens address of a **Resource** in **Browser** (`https://example.com/entries/123`).  

1. **Browser** *(Any)*  
sends **Request** to the App (Rails)  
  ```
  GET /entries/123 HTTP/1.1
  Host: example.com
  ```

1. **Controller** *(Rails)*  
runs the requested `#action` on the Resource (by convention of the same name as itself). The example is a show action, so
    - it fetches the requested instance of the **Model** from the Database (otherwise, it could be several list of things)  
    ```ruby
    entry = Entries.find(123)
    ```
    - and sets up a specific **Presenter** for it  
    ```ruby
    @get = EntriesPresenter.new(entry)
    ```
    - it could also call the **View**, but this is implicitly done by convention because it is resourceful
    ```ruby
    # implicitly called by Rails:
    # render(template: 'entries/show', layout: 'application')
    # receives @get = #<Presenter #<Entry id=123>`
    ```

1. **Presenter** *(custom module)*  
provides access to all the (sections of) data needed to render the Resource in the context of the action *(possibly also from related Resources)*. All further calls to the Database (ActiveRecord) are encapsulated here!
    ```ruby
    # … module Presenter::Entries …
    class EntryShow < Presenter
    def initialize(resource)
    @resource = resource
    end
    def title
    @resource.title
    end
    # … def image_url …
    end
    ```

1. **View** *(Rails)*,  
template is called and builds the HTML output using **UI Elements** (SASS/CSS, see [Styleguide](http://test.madek.zhdk.ch/styleguide/))
    ```haml
    -# views/entries/show.haml
    = deco('entry-overview')
    ```

    - **Layout** *(Rails)* – everything is wrapped in it.  
    `layouts/_base` has a very basic HTML structure and is not used directly.  
    `layouts/application` and more specific ones inherit directly from it.  
    No further nesting allowed, it gets too messy with the blocks.  
        ```haml
        -# simple non-nesting app layout:
        %head
          %script{src: '/app.js'}
          %title= if content_for?(:title) ? content_for(:title) : "My App"
        %body.app
          = yield
        ```

    -  **Decorator** *(custom helper)*,  
    a reusable partial specific of the application,
    it also receives a specific **Presenter**.  
    Serves as the "glue" between the domain-specific methods
    of a Presenter and the visual structure and semantics of a design library (see the commments in the code below).  
    Note that this is a contrived example and the decorator might seem pointless (as it could be in the view),
      but it's used many parts of the app
      (not all of them resourceful, many handling large lists, …).

      ```ruby
      -# elements/decorators/entry-overview.haml
      :ruby
        return unless @get.is_a?(Presenter)
        entry = {
          title: @get.title,
          # note the section name, a ui combo does not know what 'privacy' is!
          badge_top_left: component("icon.#{@get.privacy}"),
          picture: component('thumbnail', {
            picture: @get.image_url,
            text: @get.title
            })
          }
      ```
      ```haml
      .the-unavoidable-entry-oberview-wrapper{data: { id: @get.id, type: 'entry' }}
        = combo('resource-overview', entry)
      ```

    - **Combo** *(custom helper)*,  
    a large visual UI Element, combing several smaller elements.  
        ```ruby
        -# elements/combos/resource-overview.haml
          return unless text && picture
        ```
        ```haml
        .ui-resource-overview
        - if badge_top_left
        .resource-badge-top-left= badge_top_left
        .ui-resource-picture= picture
        .ui-resource-title= text
        ```

    - **Component** *(custom helper)*,  
    a basic visual UI Element with some abstractions
        ```ruby
        -# elements/components/thumbnail.haml
        :ruby
          return unless href
        ```

        ```haml
        .ui-thumbnail{data: data}
          %img{class: mods, src: href, alt: text}
        ```

    - **Atom** *(HAML)*,  
    the smallest possible UI Element (a HTML Element/DOM Node).
        ```haml
        %htmlelement.some-class{key: value}
          = content_or_not
        ```

1. When HTML rendering is finished it is sent as a **Response** to the Request.
  ```
  HTTP/1.1 200 OK
  Content-Type: text/html; charset=UTF-8
  …

  <html>
    …
  </html>
  ```

1. **Browser**  
receives the HTML and parses it, and downloads important external files like styles and scripts.
The tree of content if build from the HTML, JavaScript begins to run, styles from CSS are applied, all other external file like images in the content are starting to download to be added later. The **User** can consume the website.


**Extra steps**, good to know to really understand the code base, especially non-resourceful stuff:

- **Request** goes to `routes.rb` to decide which **Controller** should handle it.
`<controller=entries, id=123, action=show, …>`

## Misc. Notable things

- all smaller elements can be used in any larger element.
this is escpecially important for Combos, as they receive mostly (prerendered) components
- some Combos and Components can also receive a block, where it makes sense for nesting
- all elements only use their given args, no ActiveRecord, no @vars (except between Presenters/Decorators)
- render nil if no minimum data is given (less `= icon if icon`). throw when something is obviouly wrong.
- still log warnings for things that are strange (possibly broken)
- some elements pass through all "extra" config keys to HAML/HTML
(where it make sense, ie. it is closely related to a HTML tag, like icon)
- custom helpers are all in one module ([source](https://github.com/zhdk/madek/blob/madek-v3/app/helpers/ui_helper.rb#L2)), plus the Presenter.
- the reference for all (custom) UI Elements is in `views/styleguide`
- in testing, every example in the styleguide is rendered (headless) and (SHA1) compared against a reference image to catch errors and (browser) changes early

test

![svg](data: image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bD0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiB2aWV3Qm94PSIzNiAxOTkgNzM0IDEzOCIgd2lkdGg9IjczNHB0IiBoZWlnaHQ9IjEzOHB0IiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPjxtZXRhZGF0YT4gUHJvZHVjZWQgYnkgT21uaUdyYWZmbGUgNi4wLjUgPGRjOmRhdGU+MjAxNS0wMS0zMSAwMDo0Nlo8L2RjOmRhdGU+PC9tZXRhZGF0YT48ZGVmcz48Zm9udC1mYWNlIGZvbnQtZmFtaWx5PSJJbnB1dCBTYW5zIE5hcnJvdyIgZm9udC1zaXplPSIyNiIgcGFub3NlLTE9IjIgMCA2IDAgMyAwIDAgOSAwIDQiIHVuaXRzLXBlci1lbT0iMTAwMCIgdW5kZXJsaW5lLXBvc2l0aW9uPSIwIiB1bmRlcmxpbmUtdGhpY2tuZXNzPSI1NC40OTY1IiBzbG9wZT0iMCIgeC1oZWlnaHQ9IjU1NC41NDU0NSIgY2FwLWhlaWdodD0iNzM2LjM2MzY0IiBhc2NlbnQ9Ijc3Mi43MjAzNCIgZGVzY2VudD0iLTIyNy4yNzk2NiIgZm9udC13ZWlnaHQ9IjYwMCIgZm9udC1zdHJldGNoPSJjb25kZW5zZWQiPjxmb250LWZhY2Utc3JjPjxmb250LWZhY2UtbmFtZSBuYW1lPSJJbnB1dFNhbnNOYXJyb3ctTWVkaXVtIi8+PC9mb250LWZhY2Utc3JjPjwvZm9udC1mYWNlPjxtYXJrZXIgb3JpZW50PSJhdXRvIiBvdmVyZmxvdz0idmlzaWJsZSIgbWFya2VyVW5pdHM9InN0cm9rZVdpZHRoIiBpZD0iRmlsbGVkQXJyb3dfTWFya2VyIiB2aWV3Qm94PSItMSAtMyA2IDYiIG1hcmtlcldpZHRoPSI2IiBtYXJrZXJIZWlnaHQ9IjYiIGNvbG9yPSJibGFjayI+PGc+PHBhdGggZD0iTSAzLjczMzMzMzMgMCBMIDAgLTEuNCBMIDAgMS40IFoiIGZpbGw9ImN1cnJlbnRDb2xvciIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMSIvPjwvZz48L21hcmtlcj48bWFya2VyIG9yaWVudD0iYXV0byIgb3ZlcmZsb3c9InZpc2libGUiIG1hcmtlclVuaXRzPSJzdHJva2VXaWR0aCIgaWQ9IkZpbGxlZEFycm93X01hcmtlcl8yIiB2aWV3Qm94PSItNSAtMyA2IDYiIG1hcmtlcldpZHRoPSI2IiBtYXJrZXJIZWlnaHQ9IjYiIGNvbG9yPSJibGFjayI+PGc+PHBhdGggZD0iTSAtMy43MzMzMzMzIDAgTCAwIDEuNCBMIDAgLTEuNCBaIiBmaWxsPSJjdXJyZW50Q29sb3IiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjEiLz48L2c+PC9tYXJrZXI+PC9kZWZzPjxnIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLW9wYWNpdHk9IjEiIHN0cm9rZS1kYXNoYXJyYXk9Im5vbmUiIGZpbGw9Im5vbmUiIGZpbGwtb3BhY2l0eT0iMSI+PHRpdGxlPkNhbnZhcyAxPC90aXRsZT48cmVjdCBmaWxsPSJ3aGl0ZSIgd2lkdGg9IjgwNiIgaGVpZ2h0PSI1MzYiLz48Zz48dGl0bGU+TGF5ZXIgMTwvdGl0bGU+PHJlY3QgeD0iNDguNjY5MjkzIiB5PSIyMTEuMzA3MDkiIHdpZHRoPSIxOTguNDI1MiIgaGVpZ2h0PSIxMTMuMzg1ODI2IiBmaWxsPSIjODFmZmRjIi8+PHJlY3QgeD0iNDguNjY5MjkzIiB5PSIyMTEuMzA3MDkiIHdpZHRoPSIxOTguNDI1MiIgaGVpZ2h0PSIxMTMuMzg1ODI2IiBzdHJva2U9ImJsYWNrIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMyIvPjx0ZXh0IHRyYW5zZm9ybT0idHJhbnNsYXRlKDUzLjY2OTI5MyAyMzcpIiBmaWxsPSJibGFjayI+PHRzcGFuIGZvbnQtZmFtaWx5PSJJbnB1dCBTYW5zIE5hcnJvdyIgZm9udC1zaXplPSIyNiIgZm9udC13ZWlnaHQ9IjYwMCIgZm9udC1zdHJldGNoPSJjb25kZW5zZWQiIHg9IjQzLjY3ODA1MiIgeT0iMjUiIHRleHRMZW5ndGg9IjEwMS4wNjkwOSI+TW9kZWwvPC90c3Bhbj48dHNwYW4gZm9udC1mYW1pbHk9IklucHV0IFNhbnMgTmFycm93IiBmb250LXNpemU9IjI2IiBmb250LXdlaWdodD0iNjAwIiBmb250LXN0cmV0Y2g9ImNvbmRlbnNlZCIgeD0iMjUuNjY3MTQzIiB5PSI1NiIgdGV4dExlbmd0aD0iMTM3LjA5MDkxIj5SZXNvdXJjZTwvdHNwYW4+PC90ZXh0PjxyZWN0IHg9IjMwMy43ODc0IiB5PSIyMTEuMzA3MDkiIHdpZHRoPSIxOTguNDI1MiIgaGVpZ2h0PSIxMTMuMzg1ODI2IiBmaWxsPSIjNmZhOWZmIi8+PHJlY3QgeD0iMzAzLjc4NzQiIHk9IjIxMS4zMDcwOSIgd2lkdGg9IjE5OC40MjUyIiBoZWlnaHQ9IjExMy4zODU4MjYiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLXdpZHRoPSIzIi8+PHRleHQgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMzA4Ljc4NzQgMjM3KSIgZmlsbD0iYmxhY2siPjx0c3BhbiBmb250LWZhbWlseT0iSW5wdXQgU2FucyBOYXJyb3ciIGZvbnQtc2l6ZT0iMjYiIGZvbnQtd2VpZ2h0PSI2MDAiIGZvbnQtc3RyZXRjaD0iY29uZGVuc2VkIiB4PSI3LjM0ODk2MTUiIHk9IjI1IiB0ZXh0TGVuZ3RoPSIxNzMuNzI3MjciPkNvbnRyb2xsZXIvPC90c3Bhbj48dHNwYW4gZm9udC1mYW1pbHk9IklucHV0IFNhbnMgTmFycm93IiBmb250LXNpemU9IjI2IiBmb250LXdlaWdodD0iNjAwIiBmb250LXN0cmV0Y2g9ImNvbmRlbnNlZCIgeD0iMjAuMzYwNzgiIHk9IjU2IiB0ZXh0TGVuZ3RoPSIxNDcuNzAzNjQiPlByZXNlbnRlcjwvdHNwYW4+PC90ZXh0PjxyZWN0IHg9IjU1OC45MDU1IiB5PSIyMTEuMzA3MDkiIHdpZHRoPSIxOTguNDI1MiIgaGVpZ2h0PSIxMTMuMzg1ODI2IiBmaWxsPSIjZmViNzZlIi8+PHJlY3QgeD0iNTU4LjkwNTUiIHk9IjIxMS4zMDcwOSIgd2lkdGg9IjE5OC40MjUyIiBoZWlnaHQ9IjExMy4zODU4MjYiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLXdpZHRoPSIzIi8+PHRleHQgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNTYzLjkwNTUgMjM3KSIgZmlsbD0iYmxhY2siPjx0c3BhbiBmb250LWZhbWlseT0iSW5wdXQgU2FucyBOYXJyb3ciIGZvbnQtc2l6ZT0iMjYiIGZvbnQtd2VpZ2h0PSI2MDAiIGZvbnQtc3RyZXRjaD0iY29uZGVuc2VkIiB4PSI1Mi44NzI1OTgiIHk9IjI1IiB0ZXh0TGVuZ3RoPSI4Mi42OCI+Vmlldy88L3RzcGFuPjx0c3BhbiBmb250LWZhbWlseT0iSW5wdXQgU2FucyBOYXJyb3ciIGZvbnQtc2l6ZT0iMjYiIGZvbnQtd2VpZ2h0PSI2MDAiIGZvbnQtc3RyZXRjaD0iY29uZGVuc2VkIiB4PSIxOC43NDE2ODkiIHk9IjU2IiB0ZXh0TGVuZ3RoPSIxMDQuOTkyNzMiPkRlY29yYTwvdHNwYW4+PHRzcGFuIGZvbnQtZmFtaWx5PSJJbnB1dCBTYW5zIE5hcnJvdyIgZm9udC1zaXplPSIyNiIgZm9udC13ZWlnaHQ9IjYwMCIgZm9udC1zdHJldGNoPSJjb25kZW5zZWQiIHg9IjEyMi42MjM1MSIgeT0iNTYiIHRleHRMZW5ndGg9IjQ3LjA2Ij50b3I8L3RzcGFuPjwvdGV4dD48bGluZSB4MT0iMjY0LjQ5NDQ5IiB5MT0iMjY4IiB4Mj0iMjg2LjM4NzQiIHkyPSIyNjgiIG1hcmtlci1lbmQ9InVybCgjRmlsbGVkQXJyb3dfTWFya2VyKSIgbWFya2VyLXN0YXJ0PSJ1cmwoI0ZpbGxlZEFycm93X01hcmtlcl8yKSIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBzdHJva2Utd2lkdGg9IjMiLz48bGluZSB4MT0iNTQxLjUwNTUiIHkxPSIyNjgiIHgyPSI1MTkuNjEyNiIgeTI9IjI2OCIgbWFya2VyLWVuZD0idXJsKCNGaWxsZWRBcnJvd19NYXJrZXIpIiBtYXJrZXItc3RhcnQ9InVybCgjRmlsbGVkQXJyb3dfTWFya2VyXzIpIiBzdHJva2U9ImJsYWNrIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS13aWR0aD0iMyIvPjwvZz48L2c+PC9zdmc+Cg==)
