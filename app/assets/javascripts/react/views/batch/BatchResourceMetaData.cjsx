React = require('react')
f = require('active-lodash')
cx = require('classnames')
setUrlParams = require('../../../lib/set-params-for-url.coffee')
t = require('../../../lib/string-translation')('de')

Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')
BatchResourceMetaDataForm = require('../../decorators/BatchResourceMetaDataForm.cjsx')
ResourcesBatchBox = require('../../decorators/ResourcesBatchBox.cjsx')
TabContent = require('../../views/TabContent.cjsx')
PageContent = require('../../views/PageContent.cjsx')
PageContentHeader = require('../../views/PageContentHeader.cjsx')

module.exports = React.createClass
  displayName: 'BatchResourceMetaDataPage'

  render: ({get, authToken, batchType} = @props) ->

    pre_title = t('meta_data_batch_title_pre')
    post_title =
      if batchType == 'MediaEntry'
        t('meta_data_batch_title_post_media_entries')
      else
        t('meta_data_batch_title_post_collections')

    pageTitle = pre_title + get.batch_entries.length + post_title

    editByContextTitle = t('media_entry_meta_data_edit_by_context_btn')
    editByContextUrl = setUrlParams('/entries/batch_edit_context_meta_data',
      id: f.map(get.batch_entries, 'uuid')
      return_to: get.return_to)

    <PageContent>
      <PageContentHeader icon='pen' title={pageTitle}>
        <Button title={editByContextTitle} href={editByContextUrl}>
          <Icon i={'arrow-up'}/>
        </Button>
      </PageContentHeader>

      <ResourcesBatchBox resources={get.resources.resources} authToken={authToken} />

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <BatchResourceMetaDataForm get={get} authToken={authToken} />
        </div>
      </TabContent>
    </PageContent>
