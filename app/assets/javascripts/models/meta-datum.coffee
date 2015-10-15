AppResource = require('./shared/app-resource.coffee')
MetaKey = require('./meta-key.coffee')

MetaDatum = AppResource.extend # base class
  type: 'MetaDatum'
  urlRoot: '/meta_data'
  props:
    values:
      type: 'array'
      required: true
    literal_values:
      type: 'array'
      required: true
    vocabulary_id:
      type: 'string'
      required: true
  children:
    meta_key: MetaKey


module.exports = # only subtypes are exported

  Text: MetaDatum.extend
    type: 'MetaDatumText'

  TextDate: MetaDatum.extend
    type: 'MetaDatumText'

  People: MetaDatum.extend
    type: 'MetaDatumPeople'

  Keywords: MetaDatum.extend
    type: 'MetaDatumKeywords'

  Licenses: MetaDatum.extend
    type: 'MetaDatumLicenses'
