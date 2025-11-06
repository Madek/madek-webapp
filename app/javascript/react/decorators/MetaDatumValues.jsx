// Takes a MetaDatum and displays the values according to the type.

import React from 'react'
import PropTypes from 'prop-types'
import { present, getPath } from '../../lib/utils.js'
import MadekPropTypes from '../lib/madek-prop-types.js'
import t from '../../lib/i18n-translate.js'
import UI, { labelize } from '../ui-components/index.js'
import MetaDatumRolesCloud from './MetaDatumRolesCloud.jsx'
import MetaDatumText from './MetaDatumText.jsx'

const prettifyJson = obj => {
  try {
    return JSON.stringify(obj, 0, 2)
  } catch (error) {
    console.error(`MetaDatumJSON: ${error}`)
    return String(obj)
  }
}

// Decorator for each type is single stateless-function-component,
// the main/exported component just selects the right one.
const DecoratorsByType = {
  Text({ values, metaKeyId }) {
    return <MetaDatumText values={values} allowReadMore={metaKeyId === 'madek_core:description'} />
  },

  TextDate({ values }) {
    return (
      <ul className="inline">
        {values.map(string => (
          <li key={string}>{string}</li>
        ))}
      </ul>
    )
  },

  JSON({ values, apiUrl }) {
    return (
      <ul className="inline ui-md-json">
        {values.map((obj, i) => (
          <li
            className="wrapped-textarea"
            style={{
              display: 'block',
              padding: 0,
              overflow: 'hidden'
            }}
            key={i}>
            <textarea
              readOnly={true}
              className="code block"
              rows={10}
              style={{
                margin: 0,
                padding: 0,
                fontSize: '85%',
                borderTop: 'none',
                borderLeft: 'none',
                borderRight: 'none'
              }}
              defaultValue={prettifyJson(obj)}
            />
            <small style={{ fontSize: '85%', display: 'block', padding: '0.5rem' }}>
              <a href={apiUrl}>
                <UI.Icon i="dload" /> {t('meta_datum_json_download_value')}
              </a>
            </small>
          </li>
        ))}
      </ul>
    )
  },

  People({ values, metaKeyId, withRoles }) {
    return withRoles ? (
      <MetaDatumRolesCloud personRoleTuples={values} metaKeyId={metaKeyId} />
    ) : (
      <UI.TagCloud mod="person" mods="small" list={labelize(values)} />
    )
  },

  Groups({ values }) {
    return <UI.TagCloud mod="group" mods="small" list={labelize(values)} />
  },

  Keywords({ values }) {
    return <UI.TagCloud mod="label" mods="small" list={labelize(values)} />
  },

  MediaEntry({ values }) {
    const [resource, description] = getPath(values, '0') || []
    const { url, title, unAuthorized, notFound } = resource || {}
    return (
      <div>
        <UI.Link href={url} className="link">
          {title}
        </UI.Link>{' '}
        {present(description) && <p>({description})</p>}
        {!!unAuthorized && (
          <p style={{ fontStyle: 'italic' }}>{t('meta_datum_media_entry_value_unauthorized')}</p>
        )}
        {!!notFound && (
          <p style={{ fontStyle: 'italic' }}>{t('meta_datum_media_entry_value_not_found')}</p>
        )}
      </div>
    )
  }
}

const MetaDatumValues = ({ metaDatum, tagMods }) => {
  const { type, values, api_data_stream_url, meta_key_id } = metaDatum
  const DecoratorByType = DecoratorsByType[type.split('::').pop()]
  return (
    <DecoratorByType
      values={values}
      tagMods={tagMods}
      apiUrl={api_data_stream_url}
      metaKeyId={meta_key_id}
      withRoles={metaDatum.meta_key.with_roles}
    />
  )
}

MetaDatumValues.propTypes = {
  metaDatum: MadekPropTypes.metaDatum.isRequired,
  tagMods: PropTypes.any
}

export default MetaDatumValues
module.exports = MetaDatumValues
