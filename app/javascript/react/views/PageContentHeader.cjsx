React = require('react')

# This is just a wrapper around PageHader.js in order to map `children` to `actions` prop
PageHeader = require('../ui-components/PageHeader.js')

module.exports = React.createClass
  displayName: 'PageContentHeader'

  render: ({icon, title, children, workflow, banner, sectionLabels} = @props) ->
    <PageHeader 
      icon={icon}
      title={title}
      actions={children}
      workflow={workflow}
      banner={banner}
      sectionLabels={sectionLabels}
    />
