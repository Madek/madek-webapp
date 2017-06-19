var get = require('lodash/get')
var ampersandApp = require('ampersand-app')

function currentLocale() {
  return get(ampersandApp, 'config.userLanguage')
}

module.exports = currentLocale
