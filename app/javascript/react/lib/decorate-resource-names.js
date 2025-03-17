/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'

const decorators = {
  User: o => o.label,
  Person(o, withRole) {
    if (withRole == null) {
      withRole = true
    }
    if (f.present(o.role) || o.isNew) {
      return buildPersonName(o, withRole)
    } else {
      return o.name
    }
  },
  InstitutionalGroup(o) {
    return o.detailed_name
  },
  Group(o) {
    return o.name
  },
  Keyword(o) {
    return o.label
  },
  ApiClient(o) {
    return `[API] ${o.login}`
  },
  Delegation(o) {
    return o.label
  }
}

module.exports = function (o) {
  let decorate
  if (!f.isObject(o) || !f.isFunction((decorate = decorators[o.type]))) {
    throw new Error(
      'Decorator: Unknown Resource! Type: ' + o.type + ' Object: ' + JSON.stringify(o)
    )
  }

  return decorate(...arguments)
}

var buildPersonName = function (o, withRole) {
  const fullName = f.any([o.first_name, o.last_name], f.present)
    ? f.trim(`${o.first_name || ''} ${o.last_name || ''}`)
    : undefined
  const role = withRole && o.role && f.present(o, 'role.label') ? `: ${o.role.label}` : ''

  switch (false) {
    case !fullName || !f.present(o.pseudonym):
      return `${fullName} (${o.pseudonym})${role}`
    case !fullName:
      return `${fullName}${role}`
    case !o.pseudonym:
      return `${o.pseudonym}${role}`
    default:
      throw new Error('Invalid Name!')
  }
}
