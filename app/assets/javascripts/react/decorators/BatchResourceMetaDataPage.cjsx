React = require('react')
f = require('active-lodash')
cx = require('classnames')
t = require('../../lib/string-translation')('de')
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
    title = t('meta_data_batch_title_pre') + get.batch_entries.length + t('meta_data_batch_title_post')
    pagePath = '/entries/batch_edit_context_meta_data'

    <PageContent>
      <PageContentHeader icon='pen' title={title}>
        <HeaderButton
          icon={'arrow-up'} title={'TODO'} name={'TODO'}
          href={pagePath} method={'get'} authToken={authToken}>
          {
            f.map get.batch_entries, (entry) ->
              <input type='hidden' name='id[]' value={entry.uuid} />
          }
        </HeaderButton>
      </PageContentHeader>

      <ResourcesBatchBox get={get} authToken={authToken} />

      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <BatchResourceMetaDataForm get={get} authToken={authToken} />
        </div>
      </TabContent>
    </PageContent>
