React = require('react')
ReactDOM = require('react-dom')
cx = require('classnames')
f = require('lodash')
Icon = require('../ui-components/Icon.cjsx')
t = require('../../lib/string-translation.js')('de')


MediaEntryHeaderWithModal = require('./MediaEntryHeaderWithModal.cjsx')
MediaEntryTabs = require('./MediaEntryTabs.cjsx')
RelationResources = require('./Collection/RelationResources.cjsx')
Relations = require('./Collection/Relations.cjsx')
MediaEntryShow = require('./MediaEntryShow.cjsx')

MetaDataByListing = require('../decorators/MetaDataByListing.cjsx')
MediaEntryPermissions = require('./MediaEntry/MediaEntryPermissions.cjsx')
UsageData = require('../decorators/UsageData.cjsx')

module.exports = React.createClass
  displayName: 'Base'
  render: ({get, action_name, for_url} = @props) ->

    main =
      if action_name == 'more_data'
        <div className='ui-container'>
          <h3 className='title-l mbl'>
            {t('media_entry_all_metadata_title')}
          </h3>
          <MetaDataByListing list={get.meta_data.by_vocabulary} hideSeparator={true} />
        </div>


      else if f.includes(['permissions', 'permissions_edit'], action_name)
        <MediaEntryPermissions get={get.permissions} for_url={for_url} />

      else if action_name == 'usage_data'
        list = get.more_data.file_information

        [
          <UsageData key='usage_data' get={get} for_url={for_url} />
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
      <MediaEntryHeaderWithModal get={get} for_url={for_url} />
      <MediaEntryTabs get={get} for_url={for_url} />
      <div className='ui-container tab-content bordered rounded-right rounded-bottom mbh'>
        <div className='ui-container bright pal rounded-top-right rounded-bottom'>
          {main}
        </div>
      </div>
    </div>
