import React from 'react'
import MetaDatumValues from './MetaDatumValues.jsx'

const MetaDataTable = ({
  labelValuePairs,
  fallbackMsg,
  tagMods,
  listClasses = 'borderless',
  keyClasses = 'ui-summary-label',
  valueClasses = 'ui-summary-content'
}) => {
  return (
    <table className={listClasses}>
      <tbody>
        {fallbackMsg ? (
          <tr>
            <td className={keyClasses}>{fallbackMsg}</td>
          </tr>
        ) : (
          labelValuePairs.map(item => (
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

export default MetaDataTable
module.exports = MetaDataTable
