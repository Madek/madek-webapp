React = require('react')
parseMods = require('../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'Icon'
  propTypes:
    i: React.PropTypes.string.isRequired

  render: ({i} = @props)->
    <i {...@props} className={"icon-#{i} #{parseMods(@props)}"}/>
