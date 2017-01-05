React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../../lib/string-translation.js')('de')
Icon = require('../../ui-components/Icon.cjsx')
PageContent = require('../PageContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
Tabs = require('../Tabs.cjsx')
Tab = require('../Tab.cjsx')
TabContent = require('../TabContent.cjsx')
parseUrl = require('url').parse
VocabularyPage = require('./VocabularyPage.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

module.exports = React.createClass
  displayName: 'VocabularyContents'

  render: ({get, authToken, for_url} = @props) ->
    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='bright pal rounded-top-right ui-container'>
        <h2 className='title-m'>
          {t('vocabularies_contents_hint_1')}{'"' + get.vocabulary.label + '"'}{t('vocabularies_contents_hint_2')}
        </h2>
      </div>
      <MediaResourcesBox withBox={true}
        get={get.resources} authToken={authToken}
        mods={[ {bordered: false}, 'rounded-bottom' ]}
        allowListMode={false}
      />
    </VocabularyPage>
