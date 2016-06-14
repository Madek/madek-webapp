// get the mediaType from the contentType

// NOTE: Careful! "mediaType" is just Madek-internal definition
// - actually saved in DB(!)
// - for client-side, logic is copied to here
// - therefore, keep in sync with `datalayer/app/models/concerns/media_type.rb`

module.exports = function mediaTypeFromContentType (contentType) {
  if (/^image/.test(contentType)) {
    return 'image'
  }
  if (/^video/.test(contentType)) {
    return 'video'
  }
  if (/^audio/.test(contentType)) {
    return 'audio'
  }
  if (/^text/.test(contentType)) {
    return 'document'
  }
  if (/^application/.test(contentType)) { // FIXME: shouldn't this only match PDF?
    return 'document'
  }
  // fallback
  return 'other'
}
