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

Button = require('../../ui-components/Button.cjsx')
ButtonGroup = require('../../ui-components/ButtonGroup.cjsx')
libUrl = require('url')
qs = require('qs')

setUrlParams = require('../../../lib/set-params-for-url.coffee')

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

    resourceTypeSwitcher = () =>
      listConfig = get.resources.config
      currentType = qs.parse(libUrl.parse(@state.forUrl).query).type
      typeBbtns = f.compact([
        {key: 'entries', name: t('sitemap_entries')},
        {key: 'collections', name: t('sitemap_collections')}])

      return (<ButtonGroup>{typeBbtns.map (btn) =>
        isActive = currentType == btn.key || !currentType && btn.key == 'entries'
        btnUrl = setUrlParams(@state.forUrl, {type: btn.key})

        <Button {...btn}
          href={btnUrl}
          mods={if isActive then 'active'}>
          {btn.name}
        </Button>}
      </ButtonGroup>)

    <VocabularyPage page={get.page} for_url={for_url}>
      <div className='bright pal rounded-top-right ui-container'>
        <h2 className='title-m'>
          {t('vocabularies_contents_hint_1')}{'"' + get.vocabulary.label + '"'}{t('vocabularies_contents_hint_2')}
        </h2>
      </div>
      <MediaResourcesBox
        for_url={for_url} withBox={true}
        get={get.resources} authToken={authToken}
        mods={[ {bordered: false}, 'rounded-bottom' ]}
        allowListMode={false}
        toolBarMiddle={resourceTypeSwitcher()}
      />
    </VocabularyPage>