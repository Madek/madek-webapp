f = require('active-lodash')
AppResource = require('./shared/app-resource.coffee')
Permissions = require('./media-entry/permissions.coffee')
Person = require('./person.coffee')
# MediaResources = require('./shared/media-resources.coffee')
ResourceMetaData = require('./shared/resource-meta-data.coffee')
MetaData = require('./meta-data.coffee')
Favoritable = require('./concerns/resource-favoritable.coffee')

# TODO: extract more concerns from MediaEntry
module.exports = AppResource.extend(
  Favoritable, {
  type: 'Collection'
  urlRoot: '/sets'
  props:
    title:
      type: 'string'
      required: true
    description: ['string']
    copyright_notice: ['string']
    portrayed_object_date: ['string']
    image_url:
      type: 'string'
      required: true
    privacy_status:
      type: 'string'
      required: true
      default: 'private'
    keywords: ['array']
    more_data: ['object']

  children:
    permissions: Permissions
    responsible: Person

  collections:
    meta_data: MetaData
    # relations: MediaResources
})
