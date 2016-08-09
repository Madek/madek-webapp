f = require('active-lodash')

decorators =
  Person: (o)-> o.name || buildPersonName(o)
  Keyword: (o)-> o.label
  License: (o)-> o.label
  InstitutionalGroup: (o)-> o.name

module.exports = (o)->
  unless f.isObject(o) and f.isFunction(decorate = decorators[o.type])
    throw new Error('Decorator: Unknown Resource! Type: ' + o.type + ' Object: ' + JSON.stringify(o))

  decorate(o)


# TODO: move to Person model
buildPersonName = (o)->
  switch
    when f.any([o.first_name, o.last_name], f.present) and f.present(o.pseudonym)
      "#{o.first_name} #{o.last_name} (#{o.pseudonym})"
    when f.any([o.first_name, o.last_name], f.present)
      f.trim("#{o.first_name} #{o.last_name}")
    else
      o.pseudonym
