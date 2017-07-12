React = require('react')
f = require('active-lodash')
c = require('classnames')
parseMods = require('../../lib/ui.coffee').parseMods
t = require('../../../lib/string-translation')('de')
Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass
  displayName: 'StatusIcon'


  render: ({privacyStatus, resourceType, modelIsNew, modelPublished, iconClass} = @props) ->

    # map the type name:
    # type = get.type.replace(/Collection/, 'MediaSet')

    # map the privacy icon:
    # see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    # vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>

    privacyIcon = do (status = privacyStatus) ->
      iconMapping = {'public': 'open', 'private': 'private', 'shared': 'group'}
      iconName = "privacy-#{iconMapping[status]}"
      <Icon i={iconName} title={privacyStatus} className={iconClass} />

    privacyIcon
    
