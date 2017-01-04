# A list of MetaData, either by Vocabulary or by Context

React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
parseMods = require('../lib/ui.coffee').parseMods
t = require('../../lib/string-translation')('de')

MadekPropTypes = require('../lib/madek-prop-types.coffee')
MetaDatumValues = require('./MetaDatumValues.cjsx')

Icon = require('../ui-components/Icon.cjsx')


# TODO: inline Edit - MetaDatumEdit = require('../meta-datum-edit.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataList'
  propTypes:
    vocabUuid: React.PropTypes.string
    list: MadekPropTypes.metaDataByAny
    tagMods: React.PropTypes.any # TODO: mods
    type: React.PropTypes.oneOf(['list', 'table'])
    showTitle: React.PropTypes.bool
    showFallback: React.PropTypes.bool

  getDefaultProps: ()->
    type: 'list'
    showTitle: true
    showFallback: true

  _listingDataWithFallback: (list, type, showTitle, showFallback) ->
    metaData = f.get(list, 'meta_data')
    listing = f.get(list, 'context') or f.get(list, 'vocabulary')
    listingType = f.get(listing, 'type')
    throw new Error 'Invalid Data!' if (listingType && !f.include(['Context', 'Vocabulary'], listingType))

    throw new Error 'No title!' if showTitle and not f.present(listing.label)
    title = f.get(listing, 'label')

    # check for empty list:
    isEmpty = switch
      when !f.present(listing)
        true
      when listingType is 'Vocabulary'
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
        key: key.label
        value: datum
      }

    {
      title: title
      listingData: listingData
      fallbackMsg: fallbackMsg
    }

  render: ({list, tagMods, type, showTitle, showFallback, renderer} = @props)->

    {title, listingData, fallbackMsg} = @_listingDataWithFallback(
      list, type, showTitle, showFallback)

    if renderer
      renderer(listingData, fallbackMsg, tagMods)
    else

      wrapperClass = classList(parseMods(@props), 'ui-metadata-box')

      <div className={wrapperClass}>
        {if showTitle
          {# TODO: vocabulary description, privacy_status}
          <h3 className='title-l separated mbm'>
            {title}
            {' ' if @props.vocabUuid}
            {
              if @props.vocabUuid
                <a href={'/vocabulary/' + @props.vocabUuid} style={{textDecoration: 'none'}}>
                  <Icon i='link' />
                </a>
            }
          </h3>
        }
        {if type is 'list'
          <MetaDataDefinitionList
            listingData={listingData} fallbackMsg={fallbackMsg} tagMods={tagMods} />
        else
          <MetaDataTable
            listingData={listingData} fallbackMsg={fallbackMsg} tagMods={tagMods} />
        }
      </div>

MetaDataDefinitionList = ({listingData, fallbackMsg, tagMods} = props) ->
  listClasses = 'media-data'
  keyClass = 'media-data-title title-xs-alt'
  valClass = 'media-data-content'

  <dl className={listClasses}>
    {if fallbackMsg
      <dt className={keyClass}>{fallbackMsg}</dt>
    else
      f.map listingData, (item) ->
        # NOTE: weird array + keys because of <http://facebook.github.io/react/tips/maximum-number-of-jsx-root-nodes.html>
        [
          (<dt key='dt' className={keyClass}>{item.key}</dt>),
          (<dd key='dd' className={valClass}>
            <MetaDatumValues metaDatum={item.value} tagMods={tagMods}/>
          </dd>)
        ]
    }
  </dl>

MetaDataTable = ({listingData, fallbackMsg, tagMods} = props) ->
  listClasses = 'borderless'
  keyClass = 'ui-summary-label'
  valClass = 'ui-summary-content'

  <table className={listClasses}>
    <tbody>
      {if fallbackMsg
        <tr><td className={keyClass}>{fallbackMsg}</td></tr>
      else
        f.map listingData, (item) ->
          <tr key={item.key}>
            <td className={keyClass}>{item.key}</td>
            <td className={valClass}>
              <MetaDatumValues metaDatum={item.value} tagMods={tagMods}/>
            </td>
          </tr>
      }
      </tbody>
    </table>
