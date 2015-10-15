f = require('../../lib/fun.coffee')

decorators =
  Person: (o)-> o.name
  Keyword: (o)-> o.term

module.exports = (o)->
  unless f.isObject(o) and f.isFunction(decorate = decorators[o.type])
    throw new Error "Decorator: Invalid Object!"

  decorate(o)
