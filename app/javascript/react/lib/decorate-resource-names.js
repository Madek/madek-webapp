import { present } from '../../lib/present';
import { isFunction, isObject, some, trim } from 'lodash-es';

const decorators = {
  User: o => o.label,
  Person(o, withRole) {
    if (withRole == null) {
      withRole = true
    }
    if (present(o.role) || o.isNew) {
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

export default function (o) {
  let decorate
  if (!isObject(o) || !isFunction((decorate = decorators[o.type]))) {
    throw new Error(
      'Decorator: Unknown Resource! Type: ' + o.type + ' Object: ' + JSON.stringify(o)
    )
  }

  return decorate(...arguments)
}

var buildPersonName = function (o, withRole) {
  const fullName = some([o.first_name, o.last_name], present)
    ? trim(`${o.first_name || ''} ${o.last_name || ''}`)
    : undefined
  const role = withRole && o.role && present(o, 'role.label') ? `: ${o.role.label}` : ''

  switch (false) {
    case !fullName || !present(o.pseudonym):
      return `${fullName} (${o.pseudonym})${role}`
    case !fullName:
      return `${fullName}${role}`
    case !o.pseudonym:
      return `${o.pseudonym}${role}`
    default:
      throw new Error('Invalid Name!')
  }
}
