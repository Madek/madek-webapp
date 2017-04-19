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
  render: ({get, action_name, for_url} = @props) ->

    main =
      if action_name == 'relation_parents'
        <RelationResources get={get} for_url={for_url} scope='parents' />
      else if action_name == 'relation_siblings'
        <RelationResources get={get} for_url={for_url} scope='siblings' />
      else if action_name == 'relations'
        <Relations get={get} for_url={for_url} />
      else if action_name == 'show'
        <MediaEntryShow get={get} for_url={for_url} />

    <div className='app-body-ui-container'>
      <MediaEntryHeaderWithModal get={get} for_url={for_url} />
      <MediaEntryTabs get={get} for_url={for_url} />
      {main}
    </div>
