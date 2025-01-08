/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
require('./env');

//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
//         and to make the csv part of the asset manifest.
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

// global jquery. needed for jquery plugins.
window.jQuery = (window.$ = require('jquery'));

// local requires
const {
  each
} = require('active-lodash');
const {
  present
} = require('active-lodash');
const parseUrl = require('url').parse;
const buildUrl = require('url').format;

// setup APP ############################################################
// "global" singleton (returns same object no matter where it's required)
const app = require('ampersand-app');
// validate and set the "global" config - see frontend_app_config.rb
if (!present(APP_CONFIG)) { throw new Error('No `APP_CONFIG`!'); }
app.extend({
  config: require('global').APP_CONFIG
});

// init UJS #############################################################

// already in global boostrap:
// - tabs

// our library:
const ujs = [
  require('./ujs/hashviz.js'),
  require('./ujs/react.js'),
  (() => // TMP: support data-confirm attributes (legacy)
Array.prototype.slice.call(document.querySelectorAll('[data-confirm]')).map(
  node => node.onclick = () => confirm(node.dataset.confirm || 'Sind sie sicher?')
))
];

// initialize them all when DOM is ready:
$(document).ready(() => each(ujs, init => init()));

// language switcher
$(() => $('#lang_switcher').on('change', function(e) {
  const parsedUrl = parseUrl(location.href, true);
  parsedUrl.query['lang'] = $(e.currentTarget).val();
  delete parsedUrl.search;
  return window.location.href = buildUrl(parsedUrl);
}));

// DEV:
// require('./developer-tools.js')
