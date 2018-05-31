React = require('react')

ResourcesBoxWithSwitch = require('../../templates/ResourcesBoxWithSwitch.cjsx')

module.exports = React.createClass
  displayName: 'Views.MediaEntry.Index'
  propTypes:
    for_url: React.PropTypes.string.isRequired
    # all other props are just passed through to ResourcesBox:
    get: React.PropTypes.object.isRequired

  render: (props = this.props)->
    return (
      <ResourcesBoxWithSwitch saveable
        switches={currentType: 'entries', otherTypes: ['sets']}
        {...props} enableOrdering={true} enableOrderByTitle={true}
        usePathUrlReplacement={true} />
    )
