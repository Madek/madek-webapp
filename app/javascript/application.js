/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */

// ES6 imports for Vite
import jQuery from 'jquery'
import { each, present } from 'active-lodash'
import { parse as parseUrl, format as buildUrl } from 'url'
import app from 'ampersand-app'

// Import UJS modules
import hashvizUjs from './ujs/hashviz.js'
import reactUjs from './ujs/react.js'

// global jquery. needed for jquery plugins.
window.jQuery = window.$ = jQuery
// setup APP ############################################################
// "global" singleton (returns same object no matter where it's required)
// validate and set the "global" config - see frontend_app_config.rb
if (!present(APP_CONFIG)) {
  throw new Error('No `APP_CONFIG`!')
}
app.extend({
  config: window.APP_CONFIG
})

// init UJS #############################################################

// already in global boostrap:
// - tabs

// our library:
const ujs = [
  hashvizUjs,
  reactUjs,
  () =>
    // TMP: support data-confirm attributes (legacy)
    Array.prototype.slice
      .call(document.querySelectorAll('[data-confirm]'))
      .map(node => (node.onclick = () => confirm(node.dataset.confirm || 'Sind sie sicher?')))
]

// initialize them all when DOM is ready:
$(document).ready(() => each(ujs, init => init()))

// language switcher
$(() =>
  $('#lang_switcher').on('change', function (e) {
    const parsedUrl = parseUrl(location.href, true)
    parsedUrl.query['lang'] = $(e.currentTarget).val()
    delete parsedUrl.search
    return (window.location.href = buildUrl(parsedUrl))
  })
)

// DEV:
// require('./developer-tools.js')
