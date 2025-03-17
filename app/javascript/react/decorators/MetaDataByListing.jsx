/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Display multiple Rows of MetaData Lists (by Context or by Vocabulary)
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import MadekPropTypes from '../lib/madek-prop-types.js'
import MetaDataList from './MetaDataList.jsx'
import listingHelper from '../../lib/metadata-listing-helper.js'

module.exports = createReactClass({
  displayName: 'Deco.MetaDataByListing',
  propTypes: {
    list: MadekPropTypes.metaDataListing.isRequired,
    vocabLinks: PropTypes.bool
  },

  render(param) {
    // Wenn es  Werte in 1 oder 2 Kontexten gibt, dann ist die Darstellung 2-spaltig.(Bei nur 1 Kontext bleibt die zweite Spalte leer.)
    // Wenn es Werte in 3 Kontexten gibt, ist die Darstellung 3-spaltig.
    // Wenn es Werte in 4 und mehr Kontexten gibt, ist die Darstellung 4-spaltig. (Der 5+n. Kontexte rutscht in die zweite Zeile.)

    if (param == null) {
      param = this.props
    }
    const { list, hideSeparator } = param
    const onlyListsWithContent = f.reject(list, i => listingHelper._isEmptyContextOrVocab(i))
    const numVocabs = onlyListsWithContent.length
    const numColumns = f.max([2, f.min([4, numVocabs])])
    const colums = f.chunk(onlyListsWithContent, numColumns)

    return (
      <div className="meta-data-summary mbl">
        {colums.map(row => [
          <div
            className="ui-container media-entry-metadata"
            key={f(row).map('context.uuid').join()}>
            {row.map(function (data) {
              const key = (data.context || data.vocabulary).uuid
              const vocabUrl = f.get(data, 'vocabulary.url', '')
              return (
                <div className={`col1of${numColumns}`} key={key}>
                  <MetaDataList mods="prl" list={data} vocabUrl={vocabUrl} />
                </div>
              )
            })}
          </div>,
          row !== f.last(colums) ? (
            !hideSeparator ? (
              <hr key="sep" className="separator mini mvl" />
            ) : (
              <div className="mvl" />
            )
          ) : undefined
        ])}
      </div>
    )
  }
})
