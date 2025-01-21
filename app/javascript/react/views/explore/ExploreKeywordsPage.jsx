/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import Keyword from '../../ui-components/Keyword.jsx'

module.exports = createReactClass({
  displayName: 'ExploreKeywordsPage',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    return (
      <div>
        <div className="app-body-ui-container pts context-home">
          <h1 className="title-xl mtl mbm">{get.content.data.title}</h1>
          <div className="ui-resources-holder pal">
            <ul className="ui-tag-cloud" style={{ marginBottom: '40px' }}>
              {f.map(get.content.data.list, (resource, n) => (
                <Keyword
                  key={`key_${n}`}
                  label={resource.keyword.label}
                  hrefUrl={resource.keyword.url}
                  count={resource.keyword.usage_count}
                />
              ))}
            </ul>
          </div>
        </div>
      </div>
    )
  }
})
