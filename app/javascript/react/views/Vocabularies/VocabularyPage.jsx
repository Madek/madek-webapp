import React from 'react'
import t from '../../../lib/i18n-translate.js'
import Icon from '../../ui-components/Icon.jsx'
import PageContent from '../PageContent.jsx'
import PageHeader from '../../ui-components/PageHeader.js'
import Tabs from '../Tabs.jsx'
import Tab from '../Tab.jsx'
import TabContent from '../TabContent.jsx'
import { parse as parseUrl } from 'url'

const parseUrlState = location => parseUrl(location).pathname

const VocabularyPage = ({ page, for_url, children }) => {
  const { label } = page.vocabulary
  const { actions } = page
  const currentPath = parseUrlState(for_url)

  const tabsConfig = [
    {
      visible: true,
      path: actions.vocabulary,
      label: t('vocabularies_tabs_vocabulary')
    },
    {
      visible: page.show_keywords,
      path: actions.vocabulary_keywords,
      label: t('vocabularies_tabs_keywords')
    },
    {
      visible: page.show_people,
      path: actions.vocabulary_people,
      label: t('vocabularies_tabs_people')
    },
    {
      visible: true,
      path: actions.vocabulary_contents,
      label: t('vocabularies_tabs_contents')
    },
    {
      visible: true,
      path: actions.vocabulary_permissions,
      label: t('vocabularies_tabs_permissions')
    }
  ]

  const headerActions = (
    <a href={actions.index} className="button">
      <Icon i="undo" /> {t('vocabularies_all')}
    </a>
  )

  return (
    <PageContent>
      <PageHeader title={label} icon="tags" actions={headerActions} />
      <Tabs>
        {tabsConfig.map(tab => {
          if (tab.visible || tab.path === currentPath) {
            return (
              <Tab
                label={tab.label}
                href={tab.path}
                key={`tab_${tab.path}`}
                active={tab.path === currentPath}
              />
            )
          }
          return null
        })}
      </Tabs>
      <TabContent>{children}</TabContent>
    </PageContent>
  )
}

export default VocabularyPage
module.exports = VocabularyPage
