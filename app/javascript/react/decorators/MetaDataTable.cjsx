React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
MetaDatumValues = require('./MetaDatumValues.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataTable'

  render: ({labelValuePairs, fallbackMsg, tagMods, listClasses, keyClasses, valueClasses} = @props) ->
    listClasses = 'borderless' unless listClasses
    keyClasses = 'ui-summary-label' unless keyClasses
    valueClasses = 'ui-summary-content' unless valueClasses

    <table className={listClasses}>
      <tbody>
        {
          if fallbackMsg
            <tr><td className={keyClasses}>{fallbackMsg}</td></tr>
          else
            f.map labelValuePairs, (item) ->
              <tr key={item.key}>
                <td className={keyClasses}>{item.label}</td>
                <td className={valueClasses}>
                  {
                    if item.type == 'datum'
                      <MetaDatumValues metaDatum={item.value} tagMods={tagMods}/>
                    else
                      item.value
                  }
                </td>
              </tr>
          }
        </tbody>
      </table>
