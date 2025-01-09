/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const c = require('classnames')
const { parseMods } = require('../../lib/ui.js')
const t = require('../../../lib/i18n-translate.js')
const Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass({
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
    const { privacyStatus, resourceType, modelPublished, iconClass } = param
    const privacyIcon = (function(status) {
      const iconMapping = { public: 'open', private: 'private', shared: 'group' }
      const iconName = `privacy-${iconMapping[status]}`
      return <Icon i={iconName} title={privacyStatus} className={iconClass} />
    })(privacyStatus)

    return privacyIcon
  }
})
