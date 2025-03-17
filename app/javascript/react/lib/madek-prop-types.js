import f from 'active-lodash'
import PropTypes from 'prop-types'
import validateUUID from 'uuid-validate'

let M

// Define all PropTypes that directly relate to Models/Presenters here.
// NOTE: Never set the top-level as `isRequired`, that is up to the Component!

// # Constants
const NAMESPACE_MATCH = '[a-z0-9-_]+'
const MKEY_REGEX = RegExp(`^${NAMESPACE_MATCH}:${NAMESPACE_MATCH}$`)
const META_DATUM_TYPES = [
  'MetaDatum::Text',
  'MetaDatum::TextDate',
  'MetaDatum::People',
  'MetaDatum::Roles',
  'MetaDatum::Keywords',
  'MetaDatum::JSON',
  'MetaDatum::MediaEntry'
]
const PEOPLE_SUBTYPES = ['Person', 'PeopleGroup', 'PeopleInstitutionalGroup']

// Set up base object, so that each single definition is standalone
// and can be included/nested once defined. Shortcut just for readabilty here.
const MadekPropTypes = (M = {})

// Basics
M.uuid = function (props, propName) {
  if (!validateUUID(props[propName], 4)) {
    return new Error('Malformed uuid!')
  }
}

M.metaKeyId = function (props, propName) {
  if (!MKEY_REGEX.test(props[propName])) {
    return new Error('Malformed metaKeyId!')
  }
}

// Resources/Entities
M.user = PropTypes.object

M.vocabulary = PropTypes.shape({
  uuid: M.uuid.isRequired,
  label: PropTypes.string.isRequired,
  description: PropTypes.string,
  hint: PropTypes.string
})

M.context = PropTypes.shape({
  uuid: M.uuid.isRequired,
  label: PropTypes.string,
  description: PropTypes.string,
  hint: PropTypes.string
})

const metaKey = {
  uuid: M.metaKeyId.isRequired,
  label: PropTypes.string.isRequired,
  description: PropTypes.string,
  hint: PropTypes.string,
  is_extensible: PropTypes.bool, // only for type Keywords!
  allowed_people_subtypes: PropTypes.arrayOf(
    // only for type People!
    PropTypes.oneOf(PEOPLE_SUBTYPES)
  ),
  value_type: PropTypes.oneOf(META_DATUM_TYPES).isRequired
}

M.metaKey = PropTypes.shape(metaKey)

M.VocabularyMetaKey = PropTypes.shape(
  f.merge(metaKey, {
    scope: PropTypes.arrayOf(PropTypes.oneOf(['Entries', 'Sets'])).isRequired
  })
)

M.contextKey = PropTypes.shape({
  uuid: M.uuid.isRequired,
  position: PropTypes.number.isRequired,
  label: PropTypes.string,
  description: PropTypes.string,
  hint: PropTypes.string,
  meta_key: M.metaKey
})

M.keyword = PropTypes.shape({
  label: PropTypes.string.isRequired,
  type: PropTypes.oneOf(['Keyword'])
})

// Concern: MetaData
M.metaDatum = PropTypes.shape({
  uuid: M.uuid.isRequired,
  meta_key_id: M.metaKeyId.isRequired,
  type: PropTypes.oneOf(META_DATUM_TYPES).isRequired
})

M.metaData = PropTypes.arrayOf(M.metaDatum)

// M.metaDatumShow = PropTypes.shape
//   meta_key: M.metaKey
//   type: PropTypes.oneOf(META_DATUM_TYPES).isRequired
//   subject_media_resource: PropTypes.object.isRequired # type Resource…

M.metaDatumByContext = PropTypes.shape({
  context_key: M.contextKey.isRequired,
  meta_datum: M.metaDatum
})

M.metaDataByVocabulary = PropTypes.shape({
  vocabulary: M.vocabulary.isRequired,
  meta_data: M.metaData
})

M.metaDataByContext = PropTypes.shape({
  context: M.context.isRequired,
  meta_data: PropTypes.arrayOf(M.metaDatumByContext)
})

M.metaDataByAny = PropTypes.oneOfType([M.metaDataByVocabulary, M.metaDataByContext])

M.metaDataListing = PropTypes.arrayOf(M.metaDataByAny)

M.resourceMetaData = PropTypes.shape({
  by_vocabulary: PropTypes.arrayOf(M.metaDataByVocabulary)
})

// Concern: ResourceFilters
// NOTE: extracted only for readabilty
// comments refer to <http://madek.readthedocs.org/en/latest/filters/>
const ResourceFiltersMetaData = f.values({
  // 1
  keyUuid: PropTypes.shape({
    key: PropTypes.string.isRequired,
    value: M.uuid.isRequired
  }),
  // 2
  keyMatch: PropTypes.shape({
    key: M.metaKeyId.isRequired,
    match: PropTypes.string.isRequired
  }),
  // 3
  searchKeyType: PropTypes.shape({
    key: PropTypes.oneOf(['any']).isRequired,
    match: PropTypes.string.isRequired,
    type: PropTypes.oneOf(META_DATUM_TYPES).isRequired
  }),
  // 4
  searchKey: PropTypes.shape({
    key: PropTypes.oneOf(['any']).isRequired,
    match: PropTypes.string.isRequired
  }),
  // 5
  hasKey: PropTypes.shape({
    key: M.metaKeyId.isRequired
  }),
  // 6
  notKey: PropTypes.shape({
    not_key: M.metaKeyId.isRequired
  })
})

M.resourceFilter = PropTypes.shape({
  search: PropTypes.string,
  meta_data: PropTypes.arrayOf(PropTypes.oneOfType(ResourceFiltersMetaData)),
  media_files: PropTypes.arrayOf(
    PropTypes.shape({
      key: PropTypes.oneOf(['media_type', 'extension', 'content_type']).isRequired,
      value: PropTypes.string.isRequired
    })
  ),
  permissions: PropTypes.arrayOf(
    PropTypes.oneOfType([
      PropTypes.shape({
        key: PropTypes.oneOf(['responsible_user', 'entrusted_to_user', 'entrusted_to_group'])
          .isRequired,
        value: M.uuid.isRequired
      }),
      PropTypes.shape({
        key: PropTypes.oneOf(['public']).isRequired,
        value: PropTypes.oneOf([true, false]).isRequired
      })
    ])
  )
})

// export constants
M.META_DATUM_TYPES = META_DATUM_TYPES
M.PEOPLE_SUBTYPES = PEOPLE_SUBTYPES

module.exports = MadekPropTypes
