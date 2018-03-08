f = require('active-lodash')

decorators =
  Person: (o)-> o.name || buildPersonName(o)
  InstitutionalGroup: (o)-> o.detailed_name
  Group: (o)-> o.name
  # TODO: label-icon by rdf class
  Keyword: (o)-> o.label

module.exports = (o)->
  unless f.isObject(o) and f.isFunction(decorate = decorators[o.type])
    throw new Error('Decorator: Unknown Resource! Type: ' + o.type + ' Object: ' + JSON.stringify(o))

  decorate(o)


# TODO: move to Person model
buildPersonName = (o)->
  fullName = if f.any([o.first_name, o.last_name], f.present)
    f.trim("#{o.first_name || ''} #{o.last_name || ''}")

  switch
    when fullName and f.present(o.pseudonym) then "#{fullName} (#{o.pseudonym})"
    when fullName then fullName
    when o.pseudonym then o.pseudonym
    else throw new Error('Invalid Name!')
