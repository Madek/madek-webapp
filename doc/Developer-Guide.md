# Developer Guide


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