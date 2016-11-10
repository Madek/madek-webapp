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


parseUrlState = (location) ->
  parseUrl(location).pathname

tabsConfig = (actions) ->
  [
    {
      path: actions.vocabulary,
      label: t('vocabularies_tabs_vocabulary')
    },
    {
      path: actions.vocabulary_keywords,
      label: t('vocabularies_tabs_keywords')
    }
  ]


module.exports = React.createClass
  displayName: 'VocabularyPage'

  getInitialState: () -> {
    isMounted: false
    path: parseUrlState(@props.for_url)
  }

  componentDidMount: () ->
    @setState(isMounted: true)

  componentWillReceiveProps: (nextProps) ->
    return if nextProps.for_url is @props.for_url
    @setState(path: parseUrlState(@props.for_url))

  render: ({page} = @props) ->

    {label} = page.vocabulary
    actions = page.actions

    headerActions =
      <a href={actions.index} className='button'>
        <Icon i='undo' /> {t('vocabularies_all')}
      </a>

    <PageContent>
      <PageHeader title={label} icon='tags' actions={headerActions} />

      <Tabs>
        {
          f.map tabsConfig(actions), (tab) =>
            <Tab label={tab.label}
              href={tab.path} key={'tab_' + tab.path}
              active={tab.path == @state.path} />
        }
      </Tabs>

      <TabContent>
        {@props.children}
      </TabContent>

    </PageContent>
