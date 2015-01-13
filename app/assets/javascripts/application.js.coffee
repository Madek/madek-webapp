# global requires
window.$ = require('jquery')

# test js
hello = require('./test-module-js')
hello('jQuery version ' + $().jquery)

# test coffescript
kafi = require('./test-module-cs')
console.log "Coffescript says: #{kafi}"

console.log(require('bootstrap'));
