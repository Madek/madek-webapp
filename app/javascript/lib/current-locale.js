import { config } from './app-config.js'

function currentLocale() {
  return config?.userLanguage
}

export default currentLocale
