import get from 'lodash/get'
import ampersandApp from 'ampersand-app'

function currentLocale() {
  return get(ampersandApp, 'config.userLanguage')
}

module.exports = currentLocale
