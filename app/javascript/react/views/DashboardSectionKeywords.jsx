/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../lib/i18n-translate.js'
import TagCloud from '../ui-components/TagCloud.jsx'

module.exports = createReactClass({
  displayName: 'DashboardSectionKeywords',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { section, sectionResources } = param
    const keywords = f.map(sectionResources, keyword => {
      return {
        children: keyword.label + ' ',
        href: keyword.url,
        count: keyword.usage_count
      }
    })

    return (
      <div id={section.id}>
        <div className="ui-resources-header">
          <h2 className="title-l ui-resources-title">{section.title}</h2>
          {f.isEmpty(keywords) ? (
            <span style={{ marginLeft: '10px' }}>{t('dashboard_none_exist')}</span>
          ) : (
            <a className="strong" href={section.href}>
              {t('dashboard_show_all')}
            </a>
          )}
        </div>
        {!f.isEmpty(keywords) ? (
          <div className="ui-container pbh" style={{ paddingTop: '15px' }}>
            <TagCloud mod="label" list={keywords} />
          </div>
        ) : undefined}
      </div>
    )
  }
})
