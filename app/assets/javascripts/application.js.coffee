# global requires. needed for bootstrap, easier for plugins.
window.jQuery = window.$ = require('jquery')
require('bootstrap')
# `$#typeahead` (provides autocompletion)
require('typeahead.js/dist/typeahead.jquery.js')

# local requires
each = require('lodash/collection/each')

# TODO: remove this when first real js test is set up
# test coffescript
kafi = require('./test-module-cs')
# console.log "Coffescript says: #{kafi}"
# test js
hello = require('./test-module-js')
# hello('jQuery version ' + $().jquery)

# init UJS #############################################################

# already in global boostrap:
# - tabs

# our library:
ujs = [
  require('./lib/ujs/hashviz.coffee'),
  require('./lib/ujs/autocomplete.js')
]

# initialize them all when DOM is ready:
$(document).ready -> each ujs, (init)-> do init
