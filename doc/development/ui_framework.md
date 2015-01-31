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


## Why?

- implement each element only once: less room for errors, total consistency
- no arbitrary nesting of CSS classes (which might work or not)
- identical DOM structure everywhere, less JavaScript bug
- easier refactoring of CSS architecture later on


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


## tmp links / api, gems, conventions research
- <http://pathfindersoftware.com/2008/07/pretty-blocks-in-rails-views/>
- "Rails Builders" - formbuilder, jbuilder, xmlbuilder, …
- [rails' `form_helper.rb`](https://github.com/rails/rails/blob/f9d4b50944e09273e299ff1b3cec5638320b7ae9/actionview/lib/action_view/helpers/form_helper.rb)
- [`multiblock` gem](https://github.com/monterail/multiblock)
- [`rails-multi_block_helpers` gem](https://github.com/Selleo/rails-multi_block_helpers)
- [haml blocks and capture](https://www.ruby-forum.com/topic/2174513)
- [manual haml engine](http://stackoverflow.com/questions/9623020/rendering-haml-from-rails-helper-inside-a-loop-iteration?rq=1)
- more interesting ideas:
- [`haml_user_tags` gem](http://cgamesplay.github.io/haml_user_tags/tutorial.html)
