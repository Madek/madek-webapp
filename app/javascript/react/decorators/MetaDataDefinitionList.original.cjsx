React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
MetaDatumValues = require('./MetaDatumValues.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataDefinitionList'

  render: ({labelValuePairs, fallbackMsg, tagMods} = @props) ->
    listClasses = 'media-data'
    keyClass = 'media-data-title title-xs-alt'
    valClass = 'media-data-content'

    <dl className={listClasses}>
      {
        if fallbackMsg
          <dt className={keyClass}>{fallbackMsg}</dt>
        else
          f.map labelValuePairs, (item) ->
            # NOTE: weird array + keys because of <http://facebook.github.io/react/tips/maximum-number-of-jsx-root-nodes.html>
            [
              (<dt key={'dt_' + item.key} className={keyClass}>{item.label}</dt>),
              (<dd key={'dd_' + item.key} className={valClass}>
                {
                  if item.type == 'datum'
                    <MetaDatumValues metaDatum={item.value} tagMods={tagMods}/>
                  else
                    item.value
                }
              </dd>)
            ]
        }
    </dl>
