/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Takes a MetaDatum and displays the values according to the type.

const React = require('react')
const f = require('active-lodash')
const linkifyStr = require('linkifyjs/string')
const MadekPropTypes = require('../lib/madek-prop-types.js')
const resourceName = require('../lib/decorate-resource-names.js')
const linkifyInnerHtml = require('../lib/linkify-inner-html.js')
const t = require('../../lib/i18n-translate.js')
const UI = require('../ui-components/index.js')
const MetaDatumRolesCloud = require('./MetaDatumRolesCloud.js').default
const MetaDatumText = require('./MetaDatumText.js').default
const { labelize } = UI

// Decorator for each type is single stateless-function-component,
// the main/exported component just selects the right one.
const DecoratorsByType = {
  Text(param) {
    if (param == null) {
      param = this.props
    }
    const { values, metaKeyId } = param
    return <MetaDatumText values={values} allowReadMore={metaKeyId === 'madek_core:description'} />
  },

  TextDate(param) {
    if (param == null) {
      param = this.props
    }
    const { values } = param
    return (
      <ul className="inline">
        {values.map(string => (
          <li key={string}>{string}</li>
        ))}
      </ul>
    )
  },

  JSON(param) {
    if (param == null) {
      param = this.props
    }
    const { values, apiUrl } = param
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

  People(param) {
    if (param == null) {
      param = this.props
    }
    const { values, tagMods } = param
    return <UI.TagCloud mod="person" mods="small" list={labelize(values)} />
  },

  Roles(param) {
    if (param == null) {
      param = this.props
    }
    const { values, tagMods, metaKeyId } = param
    return <MetaDatumRolesCloud personRoleTuples={values} metaKeyId={metaKeyId} />
  },

  Groups(param) {
    if (param == null) {
      param = this.props
    }
    const { values, tagMods } = param
    return <UI.TagCloud mod="group" mods="small" list={labelize(values)} />
  },

  Keywords(param) {
    if (param == null) {
      param = this.props
    }
    const { values, tagMods } = param
    return <UI.TagCloud mod="label" mods="small" list={labelize(values)} />
  },

  MediaEntry(param) {
    if (param == null) {
      param = this.props
    }
    const { values } = param
    const [resource, description] = Array.from(f.get(values, '0'))
    const { url, title, unAuthorized, notFound } = resource
    return (
      <div>
        <UI.Link href={url} className="link">
          {title}
        </UI.Link>{' '}
        {f.present(description) && <p>({description})</p>}
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

module.exports = React.createClass({
  displayName: 'Deco.MetaDatumValues',
  propTypes: {
    metaDatum: MadekPropTypes.metaDatum.isRequired,
    tagMods: React.PropTypes.any
  },

  render(props) {
    if (props == null) {
      ;({ props } = this)
    }
    const { type, values, api_data_stream_url, tagMods, meta_key_id } = props.metaDatum
    const DecoratorByType = DecoratorsByType[f.last(type.split('::'))]
    return (
      <DecoratorByType
        values={values}
        tagMods={tagMods}
        apiUrl={api_data_stream_url}
        metaKeyId={meta_key_id}
      />
    )
  }
})

// helpers

var prettifyJson = function(obj) {
  try {
    return JSON.stringify(obj, 0, 2)
  } catch (error) {
    console.error(`MetaDatumJSON: ${error}`)
    return String(obj)
  }
}
