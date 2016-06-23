React = require('react')
t = require('../../lib/string-translation.js')('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
ResourceMetaDataForm = require('./ResourceMetaDataForm.cjsx')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')

module.exports = React.createClass
  displayName: 'ResourceMetaDataPage'

  render: ({get, authToken} = @props) ->
    editByContextUrl = setUrlParams((get.url + '/meta_data/edit_context'), return_to: get.return_to)
    editByContextTitle = t('media_entry_meta_data_edit_by_context_btn')

    <PageContent>
      <PageContentHeader icon='pen' title={t('media_entry_meta_data_header_prefix') + get.title}>
        <Button title={editByContextTitle} href={editByContextUrl}>
          <Icon i={'arrow-up'}/>
        </Button>
      </PageContentHeader>

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <ResourceMetaDataForm get={get} authToken={authToken} />
        </div>
      </TabContent>
    </PageContent>
