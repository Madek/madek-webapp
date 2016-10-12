React = require('react')

# TODO: remove this wrapper and only use UI component
PageHeader = require('../ui-components/PageHeader.js')

module.exports = React.createClass
  displayName: 'PageContentHeader'

  render: ({icon, title, children} = @props) ->
    <PageHeader icon={icon} title={title} actions={children}/>
