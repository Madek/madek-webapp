React = require('react')
f = require('lodash')
t = require('../../../lib/string-translation.js')('de')
Icon = require('../../ui-components/Icon.cjsx')
PageContent = require('../PageContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
Tabs = require('../Tabs.cjsx')
Tab = require('../Tab.cjsx')
TabContent = require('../TabContent.cjsx')

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

  render: ({get, children, location} = @props) ->
    {page} = get
    {vocabulary, actions} = page
    {label} = vocabulary
    currentPath = location.pathname

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
        {children}
      </TabContent>

    </PageContent>
