f = require('active-lodash')

decorators =
  Person: (o)->
    if f.present(o.role) or o.isNew
      buildPersonName(o)
    else
      o.name
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
  role = if o.role && f.present(o, 'role.label')
    ": #{o.role.label}"
  else
    ''

  switch
    when fullName and f.present(o.pseudonym) then "#{fullName} (#{o.pseudonym})#{role}"
    when fullName then "#{fullName}#{role}"
    when o.pseudonym then "#{o.pseudonym}#{role}"
    else throw new Error('Invalid Name!')
