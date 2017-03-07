f = require('active-lodash')
AppResource = require('./shared/app-resource.coffee')
Permissions = require('./media-entry/permissions.coffee')
Person = require('./person.coffee')
# MediaResources = require('./shared/media-resources.coffee')
MetaData = require('./meta-data.coffee')
ResourceWithRelations = require('./concerns/resource-with-relations.coffee')
ResourceWithListMetadata = require('./concerns/resource-with-list-metadata.coffee')
Favoritable = require('./concerns/resource-favoritable.coffee')
Deletable = require('./concerns/resource-deletable.coffee')

# TODO: extract more concerns from MediaEntry
module.exports = AppResource.extend(
  ResourceWithRelations,
  Favoritable,
  Deletable,
  ResourceWithListMetadata
  {
  type: 'Collection'
  urlRoot: '/sets'
  # NOTE: this allows some session-like props on presenters for simplicity:
  extraProperties: 'allow'
  props:
    title:
      type: 'string'
      required: true
    description: ['string']
    copyright_notice: ['string']
    portrayed_object_date: ['string']
    image_url:
      type: 'string'
      required: false
    privacy_status:
      type: 'string'
      required: true
      default: 'private'
    keywords: ['array']
    more_data: ['object']
    child_media_resources: ['object'] # NOTE: see ResourceWithRelations

  children:
    permissions: Permissions
    responsible: Person

  collections:
    meta_data: MetaData
})
