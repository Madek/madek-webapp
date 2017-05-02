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
libUrl = require('url')
resourceTypeSwitcher = require('../../lib/resource-type-switcher.cjsx')


module.exports = React.createClass
  displayName: 'VocabularyContents'

  getInitialState: ()-> {
    forUrl: libUrl.format(@props.get.resources.config.for_url)
  }
  componentDidMount: ()->
    @router =  require('../../../lib/router.coffee')
    @unlistenRouter = @router.listen((location) =>
      # NOTE: `location` has strange format, stringify it!
      @setState(forUrl: libUrl.format(location)))
    @router.start()

  componentWillUnmount: ()-> @unlistenRouter && @unlistenRouter()

  render: ({get, authToken, for_url} = @props) ->

    switcher = resourceTypeSwitcher(get.resources, @state.forUrl, false, null)

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='ui-container pal'>
        <h2 className='title-m'>
          {t('vocabularies_contents_hint_1')}{'"' + get.vocabulary.label + '"'}{t('vocabularies_contents_hint_2')}
        </h2>
      </div>
      <MediaResourcesBox
        for_url={for_url} withBox={true}
        get={get.resources} authToken={authToken}
        mods={[ {bordered: false}, 'rounded-bottom' ]}
        toolBarMiddle={switcher}
      />
    </VocabularyPage>
