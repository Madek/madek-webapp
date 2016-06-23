React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../lib/string-translation')('de')
setUrlParams = require('../../lib/set-params-for-url.coffee')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
RailsForm = require('../lib/forms/rails-form.cjsx')
MetaKeyFormLabel = require('../lib/forms/form-label.cjsx')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
BatchHintBox = require('./BatchHintBox.cjsx')
BatchResourceMetaDataForm = require('./BatchResourceMetaDataForm.cjsx')
TabContent = require('../views/TabContent.cjsx')
HeaderButton = require('../views/HeaderButton.cjsx')
PageContent = require('../views/PageContent.cjsx')
ResourcesBatchBox = require('./ResourcesBatchBox.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')

module.exports = React.createClass
  displayName: 'BatchResourceMetaDataPage'

  render: ({get, authToken} = @props) ->
    pageTitle = t('meta_data_batch_title_pre') + get.batch_entries.length + t('meta_data_batch_title_post')

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

      <ResourcesBatchBox get={get} authToken={authToken} />

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <BatchResourceMetaDataForm get={get} authToken={authToken} />
        </div>
      </TabContent>
    </PageContent>
