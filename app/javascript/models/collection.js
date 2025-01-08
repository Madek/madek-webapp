const f = require('active-lodash');
const AppResource = require('./shared/app-resource.coffee');
const Permissions = require('./media-entry/permissions.coffee');
const Person = require('./person.coffee');
const MetaData = require('./meta-data.coffee');
const ResourceWithRelations = require('./concerns/resource-with-relations.coffee');
const Favoritable = require('./concerns/resource-favoritable.coffee');
const Deletable = require('./concerns/resource-deletable.coffee');

module.exports = AppResource.extend(
  ResourceWithRelations,
  Favoritable,
  Deletable,
  {
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
  }
);
