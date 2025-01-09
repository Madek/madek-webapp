React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')
f = require('lodash')
Icon = require('../ui-components/Icon.cjsx')
t = require('../../lib/i18n-translate.js')

MediaEntryHeaderWithModal = require('./MediaEntryHeaderWithModal.cjsx')
MediaEntryTabs = require('./MediaEntryTabs.cjsx')
RelationResources = require('./Collection/RelationResources.cjsx')
Relations = require('./Collection/Relations.cjsx')
MediaEntryShow = require('./MediaEntryShow.cjsx')

MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
MediaEntryPermissions = require('./MediaEntry/MediaEntryPermissions.cjsx')
UsageData = require('../decorators/UsageData.cjsx')

WORKFLOW_STATES = { IN_PROGRESS: 'IN_PROGRESS', FINISHED: 'FINISHED' }

module.exports = React.createClass
  displayName: 'Base'
  render: ({get, action_name, for_url, authToken} = @props) ->

    main =
      if action_name == 'more_data'
        <div className='ui-container'>
          <h3 className='title-l mbl'>
            {t('media_entry_all_metadata_title')}
          </h3>
          <MetaDataByListing list={get.meta_data.by_vocabulary} hideSeparator={true} authToken={authToken} />
        </div>

      else if action_name is 'permissions' and f.get(get, 'workflow.status') is WORKFLOW_STATES.IN_PROGRESS
        <div className="ui-alert">
          As this Media Entry is part of the workflow "<a href={get.workflow.actions.edit.url}>{get.workflow.name}</a>",
          managing permissions is available only by changing common settings on workflow edit page which
          will be applied after finishing it.
        </div>

      else if f.includes(['permissions', 'permissions_edit'], action_name)
        <MediaEntryPermissions get={get.permissions} for_url={for_url} authToken={authToken} />

      else if action_name == 'usage_data'
        list = get.more_data.file_information

        [
          <UsageData key='usage_data' get={get} for_url={for_url} authToken={authToken} />
          ,
          <div key='file_information' className='col2of3'>
            <h3 className='title-l separated mbm'>
              {t('media_entry_file_information_title')}
            </h3>
            <div>
              {
                if list
                  <div className='ui-metadata-box'>
                    <table className='borderless'>
                      <tbody>
                        {
                          f.compact(f.map(
                            list,
                            (item) ->
                              key = item[0]
                              value = item[1]
                              mod = item[2]
                              if value
                                <tr key={key}>
                                  <td className='ui-summary-label'>{key}</td>
                                  <td className={cx('ui-summary-content', mod)}>{value}</td>
                                </tr>
                          ))
                        }
                      </tbody>
                    </table>
                  </div>
              }
            </div>
          </div>

        ]


    <div className='app-body-ui-container'>
      <MediaEntryHeaderWithModal get={get} for_url={for_url} authToken={authToken} />
      <MediaEntryTabs get={get} for_url={for_url} authToken={authToken} />
      <div className='ui-container tab-content bordered rounded-right rounded-bottom mbh'>
        <div className='ui-container bright pal rounded-top-right rounded-bottom'>
          {main}
        </div>
      </div>
    </div>
