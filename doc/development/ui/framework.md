[WIP]


# ⚠️

Note: This document is potentially confusing because it tries to explain our approach
to more than one domain simultaneously:

1. Our version of the "Model-View-Presenter/Decorator" pattern.
2. How this relates to the "Model-View-Controller" pattern in Rails.
3. Our version of "Atomic Web Design".

Here is a diagram about points *1* and *2*:

![re_present.svg](https://cdn.rawgit.com/zhdk/madek/ef9d4e4035c22b21610a5eaf1e8006b633a49081/doc/diagrams/ui_ux/re_present.png)

Point *3* is inspired by: [Brad Frost's "Atomic Web Design"](http://bradfrost.com/blog/p/atomic-web-design/),
so many more details are there.
The current approach is also based on the elements from the existing
CSS [Styleguide][]/Framework
(by [Interactive Things](http://www.interactivethings.com/)),
so the names are mixed-and-matched (see below).
"Templates" and "Pages" are not relevant to the implementation
because they are only used while iterating on the visual design framework.
They could be very loosely translated to "Layouts" and "Views".

!["Atomic Web Design"](http://bradfrost.com/wp-content/uploads/2013/06/atomic-design.png)


## UI Elements (very short API overview)

These are all just Rails View partials called with some helpers to prepare the data.

## "Atoms":
- are just HTML nodes w/ CSS styles, not partials, just HAML

## Components:
- `component(name, config = {}, &block)`
- Basic visual "Molecules".

## Combos:
- `combo(name, config = {}, &block)`
- "Organisms" composed of several Components.

## Decorators:
- `deco(name, config = {})`
- partials for specific presenters, which they receive via the @get var.

## Layouts:
- are in `views/layout`, 'helpers' already built into rails
- "API": use `content_for` to fill different parts of the layout. If important content is missed, a warning is logged.


# Resourceful Rendering Walkthrough

*Just the minimal steps needed to understand the context and flow of code and data. The more custom it is, the more details.*

## **User** *(Any)*

opens address of a **Resource** in **Browser** (`https://example.com/entries/123`).  

## **Browser** *(Any)*

sends **Request** to the App (Rails)  
```
GET /entries/123 HTTP/1.1
Host: example.com
```

## **Controller** *(Rails)*

runs the requested `#action` on the Resource (by convention of the same name as itself). The example is a show action, so it fetches the requested instance of the **Model** from the Database (otherwise, it could be several list of things)
```ruby
entry = Entries.find(123)
```

… and sets up a specific **Presenter** for it.
```ruby
@get = EntriesPresenter.new(entry)
```

It could also call the **View**, but this is implicitly done by convention because it is resourceful
```ruby
# implicitly called by Rails:
# render(template: 'entries/show', layout: 'application')
# receives @get = #<Presenter #<Entry id=123>>`
```

## **Presenter** *(custom module)*

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

## **View** *(Rails)*

template is called and builds the HTML output using **UI Elements**
(SASS/CSS, see [Styleguide][].
Below is an ordered list of all elements in order of "size", with minimal
implementation examples. All of them except "Layout" and "Atom" do not have
a distinction in vanilla Rails and are just "partials".
```haml
-# views/entries/show.haml
= deco('entry-overview')
```

### **Layout** *(Rails)*

Everything is wrapped in it.  
- `layouts/_base` has a very basic HTML structure and is not used directly.  
- `layouts/application` and more specific ones inherit directly from it.  
- Even more sub-layouts can inherit from `application` for better consistency,  
for example 'app_with_sidebar', which takes `content_for?(:page_sidebar)`, etc..

```haml
-# simple non-nesting app layout:
%head
  %script{src: '/app.js'}
  %title= if content_for?(:title) ? content_for(:title) : "My App"
%body.app
  = yield
```

### **Decorator** *(custom helper)*

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

### **Combo** *(custom helper)*

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

### **Component** *(custom helper)*

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

### **Atom** *(HAML)*

the smallest possible UI Element (a HTML Element/DOM Node)

```haml
%htmlelement.some-class{key: value}
  = content_or_not
```

## **Response**

when HTML rendering is finished it is sent as a **Response** to the Request.

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
…

<html>
  …
</html>
```

## **Browser**

receives the HTML and parses it, and downloads important external files like styles and scripts.
The tree of content if build from the HTML, JavaScript begins to run, styles from CSS are applied, all other external file like images in the content are starting to download to be added later.

## **User**

can finally consume the website.


## Extra steps

good to know to really understand the code base, especially non-resourceful stuff:

- **Request** goes to `routes.rb` to decide which **Controller** should handle it.
`<controller=entries, id=123, action=show, …>`


# Why?

- implement each element only once: less room for errors, total consistency
- elements can validate their inputs
    - e.g. no arbitrary combining of CSS classes (which might work or not)
    - e.g. `<a>` without `href` is invalid so make a `<span>`
- identical DOM structure everywhere, less JavaScript bugs
- easier refactoring of CSS architecture later on


# Misc. Notable things

- all smaller elements can be used in any larger element.
this is escpecially important for Combos, as they receive mostly (prerendered) components
- some Combos and Components can also receive a block, where it makes sense for nesting
- 'mods' are modifiers.
  Not called classes because although they (mostly) translate to CSS classes
  this is just an implementation detail and some combinations might be "invalid" etc.
- all elements only use their given args, no ActiveRecord, no @vars (except between Presenters/Decorators)
- render nil if no minimum data is given (less `= icon if icon`). throw when something is obviously wrong.
- still log warnings for things that are strange (possibly broken)
(where it make sense, ie. it is closely related to a HTML tag, like icon)
- custom helpers are all in one module ([source](https://github.com/zhdk/madek/blob/madek-v3/app/helpers/ui_helper.rb#L2)), plus the Presenter.
- the reference for all (custom) UI Elements is in `views/styleguide`
- in testing, every example in the styleguide is rendered (headless) and (SHA1) compared against a reference image to catch errors and (browser) changes early


# tmp links / api, gems, conventions research
- example of messy duplication when just using AR + partials. this would be a 'ResourceActionsMenu' Decorator.
    - <https://github.com/zhdk/madek/blob/d588d0a9592eee5395b456fc191d92a73b5faba8/app/views/media_resources/_actions.html.haml>
    - <https://github.com/zhdk/madek/blob/d588d0a9592eee5395b456fc191d92a73b5faba8/app/views/media_entries/_actions.html.haml>
    - <https://github.com/zhdk/madek/blob/d588d0a9592eee5395b456fc191d92a73b5faba8/app/views/media_sets/_actions.html.haml>
    - <https://github.com/zhdk/madek/blob/d588d0a9592eee5395b456fc191d92a73b5faba8/app/views/filter_sets/_actions.html.haml>

- <http://pathfindersoftware.com/2008/07/pretty-blocks-in-rails-views/>
- "Rails Builders" - formbuilder, jbuilder, xmlbuilder, …
- [rails' `form_helper.rb`](https://github.com/rails/rails/blob/f9d4b50944e09273e299ff1b3cec5638320b7ae9/actionview/lib/action_view/helpers/form_helper.rb)
- [`multiblock` gem](https://github.com/monterail/multiblock)
- [`rails-multi_block_helpers` gem](https://github.com/Selleo/rails-multi_block_helpers)
- [haml blocks and capture](https://www.ruby-forum.com/topic/2174513)
- [manual haml engine](http://stackoverflow.com/questions/9623020/rendering-haml-from-rails-helper-inside-a-loop-iteration?rq=1)
- [necolas: About HTML semantics and front-end architecture](http://nicolasgallagher.com/about-html-semantics-front-end-architecture/)
- [necolas: Idiomatic CSS](https://github.com/necolas/idiomatic-css)
- [mdo: Code Guide](http://codeguide.co/)
- [SRP and CSS](http://csswizardry.com/2012/04/the-single-responsibility-principle-applied-to-css/)
- more interesting ideas: [`haml_user_tags` gem](http://cgamesplay.github.io/haml_user_tags/tutorial.html)
- `cells` gem: nice ruby magic but inconsistent docs to the point of being unusable.

    > "Since version 3.9 cells comes with two "dialects": You can still use a cell like a controller. However, the new view model "dialect" supercedes the traditional cell. It allows you to treat a cell more object-oriented while providing an alternative approach to helpers.
    > While the old dialect still works, we strongly recommend using a cell as a view model." – [src](https://github.com/apotonick/cells/tree/31f6ed82b87b3f92613698442fae6fd61cc16de9#view-models)


[Styleguide]: http://test.madek.zhdk.ch/styleguide/
