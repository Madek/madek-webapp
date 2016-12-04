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

  render: ({page, for_url} = @props) ->
    {label} = page.vocabulary
    actions = page.actions
    currentPath = parseUrlState(for_url)

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
              active={tab.path == currentPath} />
        }
      </Tabs>

      <TabContent>
        {@props.children}
      </TabContent>

    </PageContent>
