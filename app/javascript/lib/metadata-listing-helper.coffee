f = require('active-lodash')

module.exports = {

  _listingFromContextOrVocab: (contextOrVocab) ->
    listing = f.get(contextOrVocab, 'context') or f.get(contextOrVocab, 'vocabulary')
    listingType = f.get(listing, 'type')
    throw new Error 'Invalid Data!' if (listingType && !f.include(['Context', 'Vocabulary'], listingType))
    {
      listing: listing,
      listingType: listingType
    }

  _isEmptyMetadataList: (metaData, listing, listingType) ->
    switch
      when !f.present(listing)
        true
      when listingType is 'Vocabulary'
        not f.some metaData, f.present
      else
        not f.some metaData, (i)-> f.present(i.meta_datum)


  _isEmptyContextOrVocab: (contextOrVocab) ->
    {listing, listingType} = @_listingFromContextOrVocab(contextOrVocab)
    @_isEmptyMetadataList(contextOrVocab.meta_data, listing, listingType)


}
