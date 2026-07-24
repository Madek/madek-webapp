import { get } from 'lodash-es'
import ampersandApp from 'ampersand-app'

function currentLocale() {
  return get(ampersandApp, 'config.userLanguage')
}

export default currentLocale
