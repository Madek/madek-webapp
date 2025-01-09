/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const cx = require('classnames')
const f = require('lodash')
const Icon = require('../ui-components/Icon.jsx')

module.exports = React.createClass({
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
