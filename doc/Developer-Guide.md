# Developer Guide

(just a stub for now, but already contains vital info previously only available in meatspace)


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

If something goes wrong in a controller (or view?), we `raise` the appropriate error class.

All error classes are defined in `ApplicationController`. 
For convenience, the classes and their names are based on HTTP error codes (4xx/5xx).
Look there for the complete list with some explanations.


### Hooks

TODO: @DrTom (just a very general guideline)

- when to use hooks, when not to
- more importantly: what to never do in certain hooks!
- point to good examples in repo