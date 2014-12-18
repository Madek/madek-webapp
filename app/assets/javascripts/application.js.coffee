# global requires
window.jQuery = require('jquery')
window.$ = window.jQuery

# test js
hello = require('./test-module-js')
hello('jQuery version ' + $().jquery)

# test coffescript
kafi = require('./test-module-cs')
console.log "Coffescript says: #{kafi}"
