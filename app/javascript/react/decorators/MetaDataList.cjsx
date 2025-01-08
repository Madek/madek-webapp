# A list of MetaData, either by Vocabulary or by Context

React = require('react')
f = require('active-lodash')
classList = require('classnames/dedupe')
parseMods = require('../lib/ui.js').parseMods
t = require('../../lib/i18n-translate.js')

MadekPropTypes = require('../lib/madek-prop-types.js')

Icon = require('../ui-components/Icon.cjsx')

VocabTitleLink = require('../ui-components/VocabTitleLink.cjsx')
listingHelper = require('../../lib/metadata-listing-helper.js')

MetaDataTable = require('./MetaDataTable.cjsx')
MetaDataDefinitionList = require('./MetaDataDefinitionList.cjsx')

module.exports = React.createClass
  displayName: 'Deco.MetaDataList'
  propTypes:
    vocabUrl: React.PropTypes.string
    list: MadekPropTypes.metaDataByAny
    tagMods: React.PropTypes.any
    type: React.PropTypes.oneOf(['list', 'table'])
    showTitle: React.PropTypes.bool
    showFallback: React.PropTypes.bool

  getDefaultProps: ()->
    type: 'list'
    showTitle: true
    showFallback: true


  _listingDataWithFallback: (list, type, showTitle, showFallback) ->
    metaData = f.get(list, 'meta_data')

    {listing, listingType} = listingHelper._listingFromContextOrVocab(list)

    throw new Error 'No title!' if showTitle and not f.present(listing.label)
    title = f.get(listing, 'label')

    # check for empty list:
    isEmpty = listingHelper._isEmptyMetadataList(metaData, listing, listingType)

    # fallback message if needed and wanted:
    fallbackMsg = if (isEmpty and showFallback)
      t('resource_meta_data_fallback')

    # build key/value pairs:
    listingData = f.map metaData, (dat)->
      # NOTE: either context or vocabulary…
      [key, label, value] = if listingType is 'Vocabulary'
        [dat.meta_key_id, dat.meta_key.label, dat]
      else
        [dat.context_key.meta_key_id, dat.context_key.label, dat.meta_datum]
      return {
        key: key
        type: 'datum'
        label: label
        value: value
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
          if @props.vocabUrl
            <VocabTitleLink text={title} href={@props.vocabUrl} separated={true} />
          else
            <h3 className='title-l separated mbm'>
              {title}
            </h3>
        }

        {
          if type is 'list'
            <MetaDataDefinitionList
              labelValuePairs={listingData} fallbackMsg={fallbackMsg} tagMods={tagMods} />
          else
            <MetaDataTable
              labelValuePairs={listingData} fallbackMsg={fallbackMsg} tagMods={tagMods}
              listClasses={@props.listClasses} keyClasses={@props.keyClasses} valueClasses={@props.valueClasses} />
        }
      </div>
