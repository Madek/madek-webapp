React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')
f = require('lodash')
Icon = require('../ui-components/Icon.cjsx')

module.exports = React.createClass
  displayName: 'MediaEntryPrivacyStatusIcon'
  render: ({get} = @props) ->

    status = get.privacy_status
    icon_map = {
      public: 'open',
      shared: 'group',
      private: 'private'
    }
    <i className={'icon-privacy-' + icon_map[status]}/>
