# A single icon (from styleguide) by name

React = require('react')
ui = require('../lib/ui.coffee')

module.exports = React.createClass
  displayName: 'Icon'
  propTypes:
    i: React.PropTypes.string.isRequired

  render: ({i} = @props)->
    <i {...@props} className={ui.cx("icon-#{i}", ui.parseMods(@props))}/>
