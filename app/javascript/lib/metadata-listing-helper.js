import { present } from './present';
import { get, includes, some } from 'lodash-es';

export default {
  _listingFromContextOrVocab(contextOrVocab) {
    const listing = get(contextOrVocab, 'context') || get(contextOrVocab, 'vocabulary')
    const listingType = get(listing, 'type')
    if (listingType && !includes(['Context', 'Vocabulary'], listingType)) {
      throw new Error('Invalid Data!')
    }
    return {
      listing,
      listingType
    }
  },

  _isEmptyMetadataList(metaData, listing, listingType) {
    switch (false) {
      case !!present(listing):
        return true
      case listingType !== 'Vocabulary':
        return !some(metaData, present);
      default:
        return !some(metaData, i => present(i.meta_datum));
    }
  },

  _isEmptyContextOrVocab(contextOrVocab) {
    const { listing, listingType } = this._listingFromContextOrVocab(contextOrVocab)
    return this._isEmptyMetadataList(contextOrVocab.meta_data, listing, listingType)
  }
}
