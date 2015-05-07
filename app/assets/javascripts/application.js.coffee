# global requires. needed for bootstrap.
window.jQuery = window.$ = require('jquery')
window.bootstrap = require('bootstrap')

# test coffescript
kafi = require('./test-module-cs')
console.log "Coffescript says: #{kafi}"

# test js
hello = require('./test-module-js')
hello('jQuery version ' + $().jquery)
