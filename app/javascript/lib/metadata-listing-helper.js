/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'

module.exports = {
  _listingFromContextOrVocab(contextOrVocab) {
    const listing = f.get(contextOrVocab, 'context') || f.get(contextOrVocab, 'vocabulary')
    const listingType = f.get(listing, 'type')
    if (listingType && !f.include(['Context', 'Vocabulary'], listingType)) {
      throw new Error('Invalid Data!')
    }
    return {
      listing,
      listingType
    }
  },

  _isEmptyMetadataList(metaData, listing, listingType) {
    switch (false) {
      case !!f.present(listing):
        return true
      case listingType !== 'Vocabulary':
        return !f.some(metaData, f.present)
      default:
        return !f.some(metaData, i => f.present(i.meta_datum))
    }
  },

  _isEmptyContextOrVocab(contextOrVocab) {
    const { listing, listingType } = this._listingFromContextOrVocab(contextOrVocab)
    return this._isEmptyMetadataList(contextOrVocab.meta_data, listing, listingType)
  }
}
