/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'

module.exports = createReactClass({
  displayName: 'MediaEntryPrivacyStatusIcon',
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    const status = get.privacy_status
    const icon_map = {
      public: 'open',
      shared: 'group',
      private: 'private'
    }
    return <i className={`icon-privacy-${icon_map[status]}`} />
  }
})
