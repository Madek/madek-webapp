# Developer Guide

(just a stub for now, but already contains vital info previously only available in meatspace)

## Datenmodell

### (Individuelle) Kontexte ((Fach-)Vokabulare)

* Kontexte enthalten Metadaten, einige Kontexte sind pro MAdeK-Instanz "global" (Core, ZHdK, etc)
* Spezifische Metadaten werden in "Individuellen Kontexten" gesammelt
* Jedem Kontext hat ein **Vokabular**, bestehend aus Keys ("Farbe") und Terms ("grün").
*  *Für Nutzer (UI, Hilfe, …) werden Kontexte und Vokabulare **nur als "Vokabular" oder "Fachvokabular" bezeichnet!***
* Ein Kontext kann einem Set direkt **zugewiesen** werden (*“initiales Set”*)
     * In diesem Fall ist der Kontext **zugewiesen** und **aktiviert**
* Jedes Set, das sich in einem *initialen Set* befindet, hat ebenfalls diesen Kontext **zugewiesen** 
    * Diese indirekten Kontexte können **aktiviert** und **deaktiviert** werden


#### Abfragen

* `media_set.contexts`: Liste aller einem Set zugewiesener Kontexte
    * `context.inherited`: True wenn Kontext dem Set *nicht* direkt zugewiesen wurde
    * `context.active`: True wenn Kontext für Set aktiviert ist (Kann nur True sein wenn `inherited` auch true ist)

* `context.media_entries `: Einträge, die sich in einem (Sub-)Set befinden, für das ein Kontext (zugewiesen und) **aktiviert** ist
    * `.count`: Wieviele Einträge sind es?
    * `.termed_count`: Wieviele Einträge **nutzen mindestens einen Term** (aus dem Kontext)?
    * Diese Liste wird auch für Popover (und in der Suche) gebraucht

* `context.vocabulary`: Liste von Keys, mit ihren Terms eines Kontexts
    * `key.order`: Ist der Key manuell oder alphabetisch sortiert?
    * `term.count`: wie viele `@context_entries` ‘nutzen’ den Term
    * `.totalcount`: höchste Zahl eines `term.count`

* `current_user.my_contexts`: Liste aller Kontexte, die für `current_user` sichtbare(?) Sets und Einträge **aktiv** sind



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