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
  displayName: 'Deco.MetaDataTable',

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { labelValuePairs, fallbackMsg, tagMods, listClasses, keyClasses, valueClasses } = param
    if (!listClasses) {
      listClasses = 'borderless'
    }
    if (!keyClasses) {
      keyClasses = 'ui-summary-label'
    }
    if (!valueClasses) {
      valueClasses = 'ui-summary-content'
    }

    return (
      <table className={listClasses}>
        <tbody>
          {fallbackMsg ? (
            <tr>
              <td className={keyClasses}>{fallbackMsg}</td>
            </tr>
          ) : (
            f.map(labelValuePairs, item => (
              <tr key={item.key}>
                <td className={keyClasses}>{item.label}</td>
                <td className={valueClasses}>
                  {item.type === 'datum' ? (
                    <MetaDatumValues metaDatum={item.value} tagMods={tagMods} />
                  ) : (
                    item.value
                  )}
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    )
  }
})
