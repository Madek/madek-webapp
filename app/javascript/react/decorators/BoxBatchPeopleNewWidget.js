import l from 'lodash'

module.exports = merged => {
  let { event, data, initial, nextProps, path } = merged

  var next = () => {
    return {
      props: nextProps,
      path: path,
      data: {
        open: nextOpen(),
        selected: nextSelected(),
        person: nextPerson(),
        group: nextGroup()
      }
    }
  }

  var validAddAction = () => {
    var person = data.person
    var group = data.group
    return (
      (event.action == 'add-person' &&
        (!l.isEmpty(person.firstname.trim()) || !l.isEmpty(person.lastname.trim()))) ||
      (event.action == 'add-group' && !l.isEmpty(group.name.trim()))
    )
  }

  var nextOpen = () => {
    if (initial) {
      return false
    } else if (event.action == 'open') {
      return true
    } else if (event.action == 'close') {
      return false
    } else if (validAddAction()) {
      return false
    } else {
      return data.open
    }
  }

  var nextSelected = () => {
    if (initial) {
      if (l.includes(nextProps.metaKey.allowed_people_subtypes, 'Person')) {
        return 'person'
      } else if (l.includes(nextProps.metaKey.allowed_people_subtypes, 'PeopleGroup')) {
        return 'group'
      } else {
        throw 'Unexpected'
      }
    } else if (event.action == 'select-tab') {
      return event.tab
    } else {
      return data.selected
    }
  }

  var nextPerson = () => {
    var nextFirstname = () => {
      if (initial) {
        return ''
      } else if (event.action == 'person-firstname') {
        return event.text
      } else if (validAddAction()) {
        return ''
      } else {
        return data.person.firstname
      }
    }

    var nextLastname = () => {
      if (initial) {
        return ''
      } else if (event.action == 'person-lastname') {
        return event.text
      } else if (validAddAction()) {
        return ''
      } else {
        return data.person.lastname
      }
    }

    var nextPseudonym = () => {
      if (initial) {
        return ''
      } else if (event.action == 'person-pseudonym') {
        return event.text
      } else if (validAddAction()) {
        return ''
      } else {
        return data.person.pseudonym
      }
    }

    return {
      firstname: nextFirstname(),
      lastname: nextLastname(),
      pseudonym: nextPseudonym()
    }
  }

  var nextGroup = () => {
    var nextName = () => {
      if (initial) {
        return ''
      } else if (event.action == 'group-name') {
        return event.text
      } else if (validAddAction()) {
        return ''
      } else {
        return data.group.name
      }
    }

    return {
      name: nextName()
    }
  }

  return next()
}
