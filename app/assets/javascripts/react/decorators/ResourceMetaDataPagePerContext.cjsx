React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
ResourceMetaDataFormPerContext = require('./ResourceMetaDataFormPerContext.cjsx')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')
HeaderButton = require('../views/HeaderButton.cjsx')

module.exports = React.createClass
  displayName: 'ResourceMetaDataPage'

  render: ({get, authToken} = @props) ->

    currentContextId = get.context_id
    if currentContextId == null
      currentContextId = get.meta_data.by_context_edit[0].context.uuid

    currentContext = null
    f.each get.meta_data.by_context_edit, (context) ->
      currentContext = context if context.context.uuid == currentContextId


    <PageContent>
      <PageContentHeader icon='pen' title={t('media_entry_meta_data_header_prefix') + get.title}>
        <HeaderButton
          icon={'arrow-down'} title={'TODO'} name={'TODO'}
          href={get.url + '/meta_data/edit'} method={'get'} authToken={authToken}/>
      </PageContentHeader>
      <Tabs>
        {f.map get.meta_data.by_context_edit, (context) ->
          <Tab privacyStatus={'public'} key={context.context.uuid} iconType={null}
            href={get.url + '/meta_data/edit_context/' + context.context.uuid}
            label={context.context.label} active={context.context.uuid == currentContextId} />
        }
      </Tabs>
      <TabContent>
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <ResourceMetaDataFormPerContext get={get} authToken={authToken} context={currentContext} />
        </div>
      </TabContent>
    </PageContent>
