React = require('react')

module.exports = React.createClass
  displayName: 'ActionsBar'
  render: ({children} = @props)->
    <div className='ui-actions'>{children}</div>
