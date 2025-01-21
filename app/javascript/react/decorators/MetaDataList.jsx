/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// A list of MetaData, either by Vocabulary or by Context

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import classList from 'classnames/dedupe'
import { parseMods } from '../lib/ui.js'
import t from '../../lib/i18n-translate.js'
import MadekPropTypes from '../lib/madek-prop-types.js'
import VocabTitleLink from '../ui-components/VocabTitleLink.jsx'
import listingHelper from '../../lib/metadata-listing-helper.js'
import MetaDataTable from './MetaDataTable.jsx'
import MetaDataDefinitionList from './MetaDataDefinitionList.jsx'

module.exports = createReactClass({
  displayName: 'Deco.MetaDataList',
  propTypes: {
    vocabUrl: PropTypes.string,
    list: MadekPropTypes.metaDataByAny,
    tagMods: PropTypes.any,
    type: PropTypes.oneOf(['list', 'table']),
    showTitle: PropTypes.bool,
    showFallback: PropTypes.bool
  },

  getDefaultProps() {
    return {
      type: 'list',
      showTitle: true,
      showFallback: true
    }
  },

  _listingDataWithFallback(list, type, showTitle, showFallback) {
    const metaData = f.get(list, 'meta_data')

    const { listing, listingType } = listingHelper._listingFromContextOrVocab(list)

    if (showTitle && !f.present(listing.label)) {
      throw new Error('No title!')
    }
    const title = f.get(listing, 'label')

    // check for empty list:
    const isEmpty = listingHelper._isEmptyMetadataList(metaData, listing, listingType)

    // fallback message if needed and wanted:
    const fallbackMsg = isEmpty && showFallback ? t('resource_meta_data_fallback') : undefined

    // build key/value pairs:
    const listingData = f.map(metaData, function(dat) {
      // NOTE: either context or vocabulary…
      const [key, label, value] = Array.from(
        listingType === 'Vocabulary'
          ? [dat.meta_key_id, dat.meta_key.label, dat]
          : [dat.context_key.meta_key_id, dat.context_key.label, dat.meta_datum]
      )
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
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { list, tagMods, type, showTitle, showFallback, renderer } = param
    const { title, listingData, fallbackMsg } = this._listingDataWithFallback(
      list,
      type,
      showTitle,
      showFallback
    )

    if (renderer) {
      return renderer(listingData, fallbackMsg, tagMods)
    } else {
      const wrapperClass = classList(parseMods(this.props), 'ui-metadata-box')

      return (
        <div className={wrapperClass}>
          {showTitle ? (
            this.props.vocabUrl ? (
              <VocabTitleLink text={title} href={this.props.vocabUrl} separated={true} />
            ) : (
              <h3 className="title-l separated mbm">{title}</h3>
            )
          ) : (
            undefined
          )}
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
              listClasses={this.props.listClasses}
              keyClasses={this.props.keyClasses}
              valueClasses={this.props.valueClasses}
            />
          )}
        </div>
      )
    }
  }
})
