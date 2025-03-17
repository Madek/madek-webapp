/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import url from 'url'
import f from 'active-lodash'
import t from './i18n-translate.js'
import History from 'history/lib/createBrowserHistory'
import useBeforeUnload from 'history/lib/useBeforeUnload'

const history = useBeforeUnload(History)()

module.exports = {
  listen: history.listen,
  start() {
    return history.replace(window.location)
  },
  goTo(path) {
    return history.push(__guard__(url.parse(path), x => x.path))
  },
  setTo(location) {
    return history.replace(location)
  },
  goBack() {
    return history.goBack()
  },

  confirmNavigation(config) {
    // NOTE: like `listen`, returns a 'stop' func
    if (config == null) {
      config = {}
    }
    const { msg, check } = f.defaults(config, {
      msg: t('app_confirm_form_leave_msg'),
      check() {
        return true
      }
    })

    // listener for page *navigation* - fn can check the new location if needed
    history.listenBefore(function (location) {
      if (check(location)) {
        return msg
      }
    })

    // listener for page *leaving* (close/refresh/…)
    // NOTE: browsers show a default text in case of "leaving",
    // BUT anyhow want a non-empty string returned…
    return history.listenBeforeUnload(function () {
      if (check()) {
        return msg
      }
    })
  }
}

function __guard__(value, transform) {
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined
}
