import React from 'react'
import MetaDatumValues from './MetaDatumValues.jsx'

const MetaDataDefinitionList = ({ labelValuePairs, fallbackMsg, tagMods }) => {
  const listClasses = 'media-data'
  const keyClass = 'media-data-title title-xs-alt'
  const valClass = 'media-data-content'

  return (
    <dl className={listClasses}>
      {fallbackMsg ? (
        <dt className={keyClass}>{fallbackMsg}</dt>
      ) : (
        labelValuePairs.map(item =>
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

export default MetaDataDefinitionList
module.exports = MetaDataDefinitionList
