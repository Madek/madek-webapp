import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

module.exports = ({ event, data, initial, path, nextProps }) => {
  var next = () => {
    return {
      props: nextProps,
      path: path,
      data: {
        text: nextText(),
        showAt: nextShowAt(),
        showFromTo: nextShowFromTo(),
        stateAt: nextStateAt(),
        stateFrom: nextStateFrom(),
        stateTo: nextStateTo(),
        selectedFrom: nextSelectedFrom(),
        selectedTo: nextSelectedTo()
      }
    }
  }

  var createPickerState = () => {
    var date = new Date()
    return {
      year: date.getFullYear(),
      month: date.getMonth()
    }
  }

  var nextText = () => {
    if (initial) {
      return ''
    }

    if (event.action == 'change-text') {
      return event.text
    } else if (event.action == 'select-at') {
      return event.text
    } else if (event.action == 'select-from-to') {
      return event.text
    } else {
      return data.text
    }
  }

  var nextStateAt = () => {
    if (initial) {
      return createPickerState()
    }

    if (event.action == 'set-month-at') {
      return event.date
    } else {
      return data.stateAt
    }
  }

  var nextStateFrom = () => {
    if (initial) {
      return createPickerState()
    }

    if (event.action == 'set-month-from') {
      return event.date
    } else {
      return data.stateFrom
    }
  }

  var nextStateTo = () => {
    if (initial) {
      return createPickerState()
    }

    if (event.action == 'set-month-to') {
      return event.date
    } else {
      return data.stateTo
    }
  }

  var nextShowAt = () => {
    if (initial) {
      return false
    }

    if (event.action == 'change-text') {
      return event.text.length == 0
    } else if (event.action == 'show-at') {
      return true
    } else if (event.action == 'show-from-to') {
      return false
    } else if (event.action == 'close-at') {
      return false
    } else if (event.action == 'select-at') {
      return false
    } else {
      return data.showAt
    }
  }

  var nextShowTo = () => {
    if (event.action == 'show-at') {
      return false
    } else {
      return data.showAt
    }
  }

  var nextShowFromTo = () => {
    if (initial) {
      false
    }

    if (event.action == 'show-from-to') {
      return true
    } else if (event.action == 'close-from-to') {
      return false
    } else if (event.action == 'select-from-to') {
      return false
    } else {
      return data.showFromTo
    }
  }

  var nextSelectedFrom = () => {
    if (initial) {
      return null
    }

    if (event.action == 'show-from-to') {
      return null
    } else if (event.action == 'select-from') {
      return event.date
    } else if (event.action == 'clear-select-from') {
      return null
    } else {
      return data.selectedFrom
    }
  }

  var nextSelectedTo = () => {
    if (initial) {
      return null
    }

    if (event.action == 'show-from-to') {
      return null
    } else if (event.action == 'select-to') {
      return event.date
    } else if (event.action == 'clear-select-to') {
      return null
    } else {
      return data.selectedTo
    }
  }

  return next()
}
