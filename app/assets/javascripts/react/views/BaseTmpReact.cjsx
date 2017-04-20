React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')
f = require('lodash')
Icon = require('../ui-components/Icon.cjsx')

MediaEntryHeaderWithModal = require('./MediaEntryHeaderWithModal.cjsx')
MediaEntryTabs = require('./MediaEntryTabs.cjsx')
RelationResources = require('./Collection/RelationResources.cjsx')
Relations = require('./Collection/Relations.cjsx')
MediaEntryShow = require('./MediaEntryShow.cjsx')

module.exports = React.createClass
  displayName: 'BaseTmpReact'
  render: ({get, action_name, for_url, authToken} = @props) ->

    main =
      if action_name == 'relation_parents'
        <RelationResources get={get} for_url={for_url} scope='parents' authToken={authToken} />
      else if action_name == 'relation_siblings'
        <RelationResources get={get} for_url={for_url} scope='siblings' authToken={authToken} />
      else if action_name == 'relations'
        <Relations get={get} for_url={for_url} authToken={authToken} />
      else if action_name == 'show'
        <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />
      else if f.includes(['export', 'ask_delete', 'select_collection'], action_name)
        <MediaEntryShow get={get} for_url={for_url} authToken={authToken} />

    <div className='app-body-ui-container'>
      <MediaEntryHeaderWithModal get={get} for_url={for_url} authToken={authToken} />
      <MediaEntryTabs get={get} for_url={for_url} authToken={authToken} />
      {main}
    </div>
