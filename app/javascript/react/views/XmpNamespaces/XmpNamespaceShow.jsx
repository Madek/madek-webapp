import React from 'react'
import t from '../../../lib/i18n-translate.js'

const propertyInfo = p => [
  [t('xmp_namespace_exiftool_key'), <samp key="key">{p.exiftool_key}</samp>],
  [t('xmp_namespace_value_type'), p.value_type],
  [t('xmp_namespace_description'), p.description],
  [
    t('xmp_namespace_meta_keys'),
    p.meta_keys.length === 0 ? null : (
      <ul className="inline" key="mks">
        {p.meta_keys.map(mk => (
          <li key={mk.id}>
            {mk.label ? (
              <span>
                <a href={mk.url}>{mk.label}</a> (<samp>{mk.id}</samp>)
              </span>
            ) : (
              <a href={mk.url}>
                <samp>{mk.id}</samp>
              </a>
            )}
          </li>
        ))}
      </ul>
    )
  ]
]

const XmpNamespaceShow = ({ get }) => {
  const { prefix, uri, label, description, properties } = get
  return (
    <div className="app-body-ui-container">
      <div className="ui-body-title">
        <div className="ui-body-title-label">
          <h1 className="title-xl">
            <samp>{prefix}</samp> {label && <span>– {label}</span>}
          </h1>
        </div>
      </div>
      <div className="ui-container tab-content bordered rounded-top rounded-bottom mbh">
        <div className="ui-container bright pal rounded-top rounded-bottom">
          <p>
            {t('xmp_namespace_uri')}: <samp>{uri}</samp>
          </p>
          {description && <p className="mtm">{description}</p>}
          <p className="mtm">
            <a href={get.template_url} className="button">
              {t('xmp_namespace_download_template')}
            </a>{' '}
            <a href={get.index_url} className="button">
              {t('xmp_namespaces_title')}
            </a>
          </p>

          <h3 className="title-m separated light mtl mbm" style={{ fontWeight: 'bold' }}>
            {t('xmp_namespace_properties')}
          </h3>
          {properties.length === 0 && <p>{t('xmp_namespace_no_properties')}</p>}
          {properties.map(p => (
            <div className="mbl" key={p.name}>
              <h4 className="title-m separated light" id={p.name}>
                <a href={'#' + p.name}>
                  <samp>{p.qualified_name}</samp>
                </a>
                {p.label && <span> – {p.label}</span>}
              </h4>
              <table className="borderless">
                <tbody>
                  {propertyInfo(p).map(([key, value]) =>
                    !value ? null : (
                      <tr key={key}>
                        <td className="ui-summary-label">{key}</td>
                        <td className="ui-summary-content">{value}</td>
                      </tr>
                    )
                  )}
                </tbody>
              </table>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export default XmpNamespaceShow
