// A list of MetaData, either by Vocabulary or by Context

import React from 'react'
import PropTypes from 'prop-types'
import { present, getPath } from '../../lib/utils.js'
import classList from 'classnames/dedupe'
import { parseMods } from '../lib/ui.js'
import t from '../../lib/i18n-translate.js'
import MadekPropTypes from '../lib/madek-prop-types.js'
import VocabTitleLink from '../ui-components/VocabTitleLink.jsx'
import listingHelper from '../../lib/metadata-listing-helper.js'
import MetaDataTable from './MetaDataTable.jsx'
import MetaDataDefinitionList from './MetaDataDefinitionList.jsx'

const getListingDataWithFallback = (list, type, showTitle, showFallback) => {
  const metaData = getPath(list, 'meta_data')

  const { listing, listingType } = listingHelper._listingFromContextOrVocab(list)

  if (showTitle && !present(listing.label)) {
    throw new Error('No title!')
  }
  const title = getPath(listing, 'label')

  // check for empty list:
  const isEmpty = listingHelper._isEmptyMetadataList(metaData, listing, listingType)

  // fallback message if needed and wanted:
  const fallbackMsg = isEmpty && showFallback ? t('resource_meta_data_fallback') : undefined

  // build key/value pairs:
  const listingData = metaData.map(dat => {
    // NOTE: either context or vocabulary…
    const [key, label, value] =
      listingType === 'Vocabulary'
        ? [dat.meta_key_id, dat.meta_key.label, dat]
        : [dat.context_key.meta_key_id, dat.context_key.label, dat.meta_datum]
    return {
      key,
      type: 'datum',
      label,
      value
    }
  })

  return {
    title,
    listingData,
    fallbackMsg
  }
}

const MetaDataList = ({
  list,
  tagMods,
  type = 'list',
  showTitle = true,
  showFallback = true,
  renderer,
  vocabUrl,
  listClasses,
  keyClasses,
  valueClasses,
  ...restProps
}) => {
  const { title, listingData, fallbackMsg } = getListingDataWithFallback(
    list,
    type,
    showTitle,
    showFallback
  )

  if (renderer) {
    return renderer(listingData, fallbackMsg, tagMods)
  }

  const wrapperClass = classList(parseMods(restProps), 'ui-metadata-box')

  return (
    <div className={wrapperClass}>
      {showTitle ? (
        vocabUrl ? (
          <VocabTitleLink text={title} href={vocabUrl} separated={true} />
        ) : (
          <h3 className="title-l separated mbm">{title}</h3>
        )
      ) : undefined}
      {type === 'list' ? (
        <MetaDataDefinitionList
          labelValuePairs={listingData}
          fallbackMsg={fallbackMsg}
          tagMods={tagMods}
        />
      ) : (
        <MetaDataTable
          labelValuePairs={listingData}
          fallbackMsg={fallbackMsg}
          tagMods={tagMods}
          listClasses={listClasses}
          keyClasses={keyClasses}
          valueClasses={valueClasses}
        />
      )}
    </div>
  )
}

MetaDataList.propTypes = {
  vocabUrl: PropTypes.string,
  list: MadekPropTypes.metaDataByAny,
  tagMods: PropTypes.any,
  type: PropTypes.oneOf(['list', 'table']),
  showTitle: PropTypes.bool,
  showFallback: PropTypes.bool
}

export default MetaDataList
module.exports = MetaDataList
