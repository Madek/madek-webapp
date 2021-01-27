f = require('active-lodash')

decorators =
  User: (o) => o.label
  Person: (o, withRole = true)->
    if f.present(o.role) or o.isNew
      buildPersonName(o, withRole)
    else
      o.name
  InstitutionalGroup: (o)-> o.detailed_name
  Group: (o)-> o.name
  # TODO: label-icon by rdf class
  Keyword: (o)-> o.label
  # TMP!
  ApiClient: (o)-> "[API] #{o.login}"
  Delegation: (o) -> o.label

module.exports = (o)->
  unless f.isObject(o) and f.isFunction(decorate = decorators[o.type])
    throw new Error('Decorator: Unknown Resource! Type: ' + o.type + ' Object: ' + JSON.stringify(o))

  decorate(arguments...)


# TODO: move to Person model
buildPersonName = (o, withRole)->
  fullName = if f.any([o.first_name, o.last_name], f.present)
    f.trim("#{o.first_name || ''} #{o.last_name || ''}")
  role = if withRole and o.role and f.present(o, 'role.label')
    ": #{o.role.label}"
  else
    ''

  switch
    when fullName and f.present(o.pseudonym) then "#{fullName} (#{o.pseudonym})#{role}"
    when fullName then "#{fullName}#{role}"
    when o.pseudonym then "#{o.pseudonym}#{role}"
    else throw new Error('Invalid Name!')
