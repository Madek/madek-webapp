/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import MetaDatumValues from './MetaDatumValues.jsx'

module.exports = createReactClass({
  displayName: 'Deco.MetaDataDefinitionList',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { labelValuePairs, fallbackMsg, tagMods } = param
    const listClasses = 'media-data'
    const keyClass = 'media-data-title title-xs-alt'
    const valClass = 'media-data-content'

    return (
      <dl className={listClasses}>
        {fallbackMsg ? (
          <dt className={keyClass}>{fallbackMsg}</dt>
        ) : (
          f.map(labelValuePairs, item =>
            // NOTE: weird array + keys because of <http://facebook.github.io/react/tips/maximum-number-of-jsx-root-nodes.html>
            [
              <dt key={`dt_${item.key}`} className={keyClass}>
                {item.label}
              </dt>,
              <dd key={`dd_${item.key}`} className={valClass}>
                {item.type === 'datum' ? (
                  <MetaDatumValues metaDatum={item.value} tagMods={tagMods} />
                ) : (
                  item.value
                )}
              </dd>
            ]
          )
        )}
      </dl>
    )
  }
})
