var get = require('lodash/get')
var ampersandApp = require('ampersand-app')

function currentLocale() {
  console.log('app-debug', ampersandApp)
  return get(ampersandApp, 'config.userLanguage')
}

module.exports = currentLocale
