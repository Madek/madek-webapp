# global jquery. needed for jquery plugins.
window.jQuery = window.$ = require('jquery')

# jquery plugins:
require('jquery-ujs')
require('bootstrap')

# local requires
each = require('lodash/collection/each')

# TODO: remove this when first real js test is set up
# test coffescript
kafi = require('./test-module-cs.coffee')
# console.log "Coffescript says: #{kafi}"
# test js
hello = require('./test-module-js')
# hello('jQuery version ' + $().jquery)


# init UJS #############################################################

# already in global boostrap:
# - tabs

# our library:
ujs = [
  require('./ujs/hashviz.coffee'),
  require('./ujs/react.coffee')
]

# initialize them all when DOM is ready:
$(document).ready -> each ujs, (init)-> do init
