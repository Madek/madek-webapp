/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */

//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
//         and to make the csv part of the asset manifest.
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

// ESM interop helper: extracts .default from ESM modules compiled to CJS
const interop = m => (m && m.__esModule ? m.default : m)

// local requires
const { each } = require('lodash-es')
const { present } = require('./lib/present.js')
const parseUrl = require('url').parse
const buildUrl = require('url').format

// setup APP ############################################################
// "global" singleton (returns same object no matter where it's required)
const app = require('ampersand-app')
// validate and set the "global" config - see frontend_app_config.rb
if (!present(APP_CONFIG)) {
  throw new Error('No `APP_CONFIG`!')
}
app.extend({
  config: require('global').APP_CONFIG
})

// init UJS #############################################################

// already in global boostrap:
// - tabs

// our library:
const ujs = [
  interop(require('./ujs/hashviz.js')),
  interop(require('./ujs/react.js')),
  () =>
    // TMP: support data-confirm attributes (legacy)
    Array.prototype.slice
      .call(document.querySelectorAll('[data-confirm]'))
      .map(node => (node.onclick = () => confirm(node.dataset.confirm || 'Sind sie sicher?')))
]

// initialize them all when DOM is ready:
document.addEventListener('DOMContentLoaded', () => each(ujs, init => init()))

// language switcher
document.addEventListener('DOMContentLoaded', () => {
  const langSwitcher = document.getElementById('lang_switcher')
  if (!langSwitcher) return
  langSwitcher.addEventListener('change', function (e) {
    const parsedUrl = parseUrl(location.href, true)
    parsedUrl.query['lang'] = e.currentTarget.value
    delete parsedUrl.search
    window.location.href = buildUrl(parsedUrl)
  })
})

// DEV:
// require('./developer-tools.js')
