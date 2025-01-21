/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import t from '../../../lib/i18n-translate.js'
import Icon from '../../ui-components/Icon.jsx'
import PageContent from '../PageContent.jsx'
import PageHeader from '../../ui-components/PageHeader.js'
import Tabs from '../Tabs.jsx'
import Tab from '../Tab.jsx'
import TabContent from '../TabContent.jsx'
import { parse as parseUrl } from 'url'

const parseUrlState = location => parseUrl(location).pathname

module.exports = createReactClass({
  displayName: 'VocabularyPage',

  _tabsConfig(actions) {
    return [
      {
        visible: true,
        path: actions.vocabulary,
        label: t('vocabularies_tabs_vocabulary')
      },
      {
        visible: this.props.page.show_keywords,
        path: actions.vocabulary_keywords,
        label: t('vocabularies_tabs_keywords')
      },
      {
        visible: this.props.page.show_people,
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
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { page, for_url } = param
    const { label } = page.vocabulary
    const { actions } = page
    const currentPath = parseUrlState(for_url)

    const headerActions = (
      <a href={actions.index} className="button">
        <Icon i="undo" /> {t('vocabularies_all')}
      </a>
    )

    return (
      <PageContent>
        <PageHeader title={label} icon="tags" actions={headerActions} />
        <Tabs>
          {f.map(this._tabsConfig(actions), function(tab) {
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
          })}
        </Tabs>
        <TabContent>{this.props.children}</TabContent>
      </PageContent>
    )
  }
})
