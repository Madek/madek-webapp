React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/i18n-translate.js')
Icon = require('../../ui-components/Icon.cjsx')
PageContent = require('../PageContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
Tabs = require('../Tabs.cjsx')
Tab = require('../Tab.cjsx')
TabContent = require('../TabContent.cjsx')
parseUrl = require('url').parse
VocabularyPage = require('./VocabularyPage.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
libUrl = require('url')


module.exports = React.createClass
  displayName: 'VocabularyContents'

  forUrl: () ->
    libUrl.format(@props.get.resources.config.for_url)

  render: ({get, authToken, for_url} = @props) ->

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='ui-container pal'>
        <h2 className='title-m'>
          {t('vocabularies_contents_hint_1')}{'"' + get.vocabulary.label + '"'}{t('vocabularies_contents_hint_2')}
        </h2>
      </div>
      <MediaResourcesBox
        for_url={for_url}
        get={get.resources} authToken={authToken}
        mods={[ {bordered: false}, 'rounded-bottom' ]}
        resourceTypeSwitcherConfig={{ showAll: false }}
        enableOrdering={true}
        enableOrderByTitle={true}
      />
    </VocabularyPage>
