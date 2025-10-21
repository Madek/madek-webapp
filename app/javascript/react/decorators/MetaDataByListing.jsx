// Display multiple Rows of MetaData Lists (by Context or by Vocabulary)
import React from 'react'
import MadekPropTypes from '../lib/madek-prop-types.js'
import MetaDataList from './MetaDataList.jsx'
import listingHelper from '../../lib/metadata-listing-helper.js'
import { get } from '../../lib/utils.js'

const MetaDataByListing = ({ list, hideSeparator }) => {
  // Wenn es  Werte in 1 oder 2 Kontexten gibt, dann ist die Darstellung 2-spaltig.(Bei nur 1 Kontext bleibt die zweite Spalte leer.)
  // Wenn es Werte in 3 Kontexten gibt, ist die Darstellung 3-spaltig.
  // Wenn es Werte in 4 und mehr Kontexten gibt, ist die Darstellung 4-spaltig. (Der 5+n. Kontexte rutscht in die zweite Zeile.)

  const onlyListsWithContent = list.filter(i => !listingHelper._isEmptyContextOrVocab(i))
  const numVocabs = onlyListsWithContent.length
  const numColumns = Math.max(2, Math.min(4, numVocabs))

  // Create chunks
  const columns = []
  for (let i = 0; i < onlyListsWithContent.length; i += numColumns) {
    columns.push(onlyListsWithContent.slice(i, i + numColumns))
  }

  return (
    <div className="meta-data-summary mbl">
      {columns.map((row, rowIndex) => [
        <div
          className="ui-container media-entry-metadata"
          key={row.map(r => (r.context || r.vocabulary).uuid).join()}>
          {row.map(data => {
            const key = (data.context || data.vocabulary).uuid
            const vocabUrl = get(data, 'vocabulary.url', '')
            return (
              <div className={`col1of${numColumns}`} key={key}>
                <MetaDataList mods="prl" list={data} vocabUrl={vocabUrl} />
              </div>
            )
          })}
        </div>,
        rowIndex !== columns.length - 1 ? (
          !hideSeparator ? (
            <hr key="sep" className="separator mini mvl" />
          ) : (
            <div className="mvl" key="sep" />
          )
        ) : null
      ])}
    </div>
  )
}

MetaDataByListing.propTypes = {
  list: MadekPropTypes.metaDataListing.isRequired
}

export default MetaDataByListing
module.exports = MetaDataByListing
