React = require('react')
parseMods = require('../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'ButtonGroup'

  render: ({children} = @props)->
    classes = "button-group #{parseMods(@props)}"

    <div {...@props} className={classes}>
      {children}
    </div>
