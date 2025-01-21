import AppResource from './shared/app-resource.js'
import Permissions from './media-entry/permissions.js'
import Person from './person.js'
import MetaData from './meta-data.js'
import ResourceWithRelations from './concerns/resource-with-relations.js'
import Favoritable from './concerns/resource-favoritable.js'
import Deletable from './concerns/resource-deletable.js'

module.exports = AppResource.extend(ResourceWithRelations, Favoritable, Deletable, {
  type: 'Collection',
  urlRoot: '/sets',
  // NOTE: this allows some session-like props on presenters for simplicity:
  extraProperties: 'allow',
  props: {
    title: {
      type: 'string',
      required: true
    },
    description: ['string'],
    copyright_notice: ['string'],
    portrayed_object_date: ['string'],
    image_url: {
      type: 'string',
      required: false
    },
    privacy_status: {
      type: 'string',
      required: true,
      default: 'private'
    },
    keywords: ['array'],
    more_data: ['object'],
    child_media_resources: ['object']
  }, // NOTE: see ResourceWithRelations

  children: {
    permissions: Permissions,
    responsible: Person
  },

  collections: {
    meta_data: MetaData
  }
})
