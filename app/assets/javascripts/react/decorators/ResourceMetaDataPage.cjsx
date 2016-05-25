React = require('react')
ResourceMetaDataForm = require('./ResourceMetaDataForm.cjsx')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')
t = require('../../lib/string-translation.js')('de')
HeaderButton = require('../views/HeaderButton.cjsx')

module.exports = React.createClass
  displayName: 'ResourceMetaDataPage'

  render: ({get, authToken} = @props) ->
    <PageContent>
      <PageContentHeader icon='pen' title={t('media_entry_meta_data_header_prefix') + get.title}>
        <HeaderButton
          icon={'arrow-up'} title={'TODO'} name={'TODO'}
          href={get.url + '/meta_data/edit_context'} method={'get'} authToken={authToken}/>
      </PageContentHeader>

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <ResourceMetaDataForm get={get} authToken={authToken} />
        </div>
      </TabContent>
    </PageContent>
