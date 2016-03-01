var babelJest = require('babel-jest')
var coffee = require('coffee-react')

module.exports = {
  process: function (src, filename) {
    if (filename.indexOf('node_modules') === -1) {
      if (filename.match(/\.coffee|\.cjsx/)) {
        src = coffee.compile(src, {bare: true})
      } else {
        src = babelJest.process(src, filename)
      }
    }
    return src
  }
}
