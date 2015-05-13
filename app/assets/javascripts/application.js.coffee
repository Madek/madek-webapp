# global requires. needed for bootstrap.
window.jQuery = window.$ = require('jquery')
window.bootstrap = require('bootstrap')

f =
  each: require('lodash/collection/each')

# test coffescript
kafi = require('./test-module-cs')
console.log "Coffescript says: #{kafi}"

# test js
hello = require('./test-module-js')
hello('jQuery version ' + $().jquery)

# init UJS #########################################################

# already in global boostrap:
# - tabs

# our library
ujs = [
  require('./lib/ujs/hashviz.coffee')
]

# initialize them all when DOM is ready
$(document).ready -> f.each ujs, (init)-> do init
