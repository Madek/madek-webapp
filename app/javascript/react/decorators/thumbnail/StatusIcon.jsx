/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import Icon from '../../ui-components/Icon.jsx'

module.exports = createReactClass({
  displayName: 'StatusIcon',

  render(param) {
    // map the type name:
    // type = get.type.replace(/Collection/, 'MediaSet')

    // map the privacy icon:
    // see <http://madek.readthedocs.org/en/latest/entities/#privacy-status>
    // vs <http://test.madek.zhdk.ch/styleguide/Icons#6.2>

    if (param == null) {
      param = this.props
    }
    const { privacyStatus, iconClass } = param
    const privacyIcon = (function (status) {
      const iconMapping = { public: 'open', private: 'private', shared: 'group' }
      const iconName = `privacy-${iconMapping[status]}`
      return <Icon i={iconName} title={privacyStatus} className={iconClass} />
    })(privacyStatus)

    return privacyIcon
  }
})
