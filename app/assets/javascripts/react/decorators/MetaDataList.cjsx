# A list of MetaData, either by Vocabulary or by Context

React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
parseMods = require('../lib/ui.coffee').parseMods
t = require('../../lib/string-translation')('de')

Link = require('../ui-components/Link.cjsx')
MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDatumValues = require('./MetaDatumValues.cjsx')

# TODO: inline Edit - MetaDatumEdit = require('../meta-datum-edit.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataList'
  propTypes:
    list: MadekPropTypes.metaDataByAny.isRequired
    tagMods: React.PropTypes.any # TODO: mods
    type: React.PropTypes.oneOf(['list', 'table'])
    showTitle: React.PropTypes.bool
    showFallback: React.PropTypes.bool

  getDefaultProps: ()->
    type: 'list'
    showTitle: true
    showFallback: true

  render: ({list, tagMods, type, showTitle, showFallback} = @props)->
    wrapperClass = classList(parseMods(@props), 'ui-metadata-box')
    metaData = list.meta_data

    listing = list.context or list.vocabulary
    listingType = listing.type
    throw new Error 'Invalid Data!' if not f.include(['Context', 'Vocabulary'], listingType)

    throw new Error 'No title!' if showTitle and not f.present(listing.label)
    title = listing.label

    # check for empty list:
    isEmpty = if listingType is 'Vocabulary'
      not f.some metaData, f.present
    else
      not f.some metaData, (i)-> f.present(i.meta_datum)

    # fallback message if needed and wanted:
    fallbackMsg = if (isEmpty and showFallback)
      t('resource_meta_data_fallback')

    # build key/value pairs:
    listingData = f.map metaData, (dat)->
      # NOTE: either context or vocabulary…
      [datum, key] = if listingType is 'Vocabulary'
        [dat, dat.meta_key]
      else
        [dat.meta_datum, dat.context_key]
      return {
        key: <Link mods='weak' href={datum.url} title={key.uuid} key={key.uuid}>{key.label}</Link>
        value: <MetaDatumValues metaDatum={datum} tagMods={tagMods}/>
      }

    <div className={wrapperClass}>
      {if showTitle
        {# TODO: vocabulary description, privacy_status}
        <h3 className='title-l separated mbm'>{title}</h3>
      }
      {if type is 'list'
        <MetaDataDefinitionList
          listingData={listingData} fallbackMsg={fallbackMsg}/>
      else
        <MetaDataTable
          listingData={listingData} fallbackMsg={fallbackMsg}/>
      }
    </div>

MetaDataDefinitionList = ({listingData, fallbackMsg} = props)->
  listClasses = 'media-data'
  keyClass = 'media-data-title title-xs-alt'
  valClass = 'media-data-content'

  <dl className={listClasses}>
    {if fallbackMsg
      <dt className={keyClass}>{fallbackMsg}</dt>
    else
      f.map listingData, (item)->
        # NOTE: weird array + keys because of <http://facebook.github.io/react/tips/maximum-number-of-jsx-root-nodes.html>
        [
          (<dt key='dt' className={keyClass}>{item.key}</dt>),
          (<dd key='dd' className={valClass}>{item.value}</dd>)
        ]
    }
  </dl>

MetaDataTable = ({listingData, fallbackMsg} = props)->
  listClasses = 'borderless'
  keyClass = 'ui-summary-label'
  valClass = 'ui-summary-content'

  <table className={listClasses}>
    <tbody>
      {if fallbackMsg
        <tr><td className={keyClass}>{fallbackMsg}</td></tr>
      else
        f.map listingData, (item)->
          <tr>
            <td className={keyClass}>{item.key}</td>
            <td className={valClass}>{item.value}</td>
          </tr>
      }
      </tbody>
    </table>
