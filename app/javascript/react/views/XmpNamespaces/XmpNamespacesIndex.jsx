import React from 'react'
import t from '../../../lib/i18n-translate.js'

const XmpNamespacesIndex = ({ get }) => {
  const { namespaces } = get
  return (
    <div className="app-body-ui-container">
      <div className="ui-body-title">
        <div className="ui-body-title-label">
          <h1 className="title-xl">{t('xmp_namespaces_title')}</h1>
        </div>
      </div>
      <div className="ui-container tab-content bordered rounded-top rounded-bottom mbh">
        <div className="ui-container bright pal rounded-top rounded-bottom">
          {namespaces.length === 0 ? (
            <p>{t('xmp_namespaces_empty')}</p>
          ) : (
            <table className="borderless">
              <tbody>
                {namespaces.map(ns => (
                  <tr key={ns.prefix}>
                    <td className="ui-summary-label">
                      <a href={ns.url}>
                        <samp>{ns.prefix}</samp>
                      </a>
                    </td>
                    <td className="ui-summary-content">
                      {ns.label && <div>{ns.label}</div>}
                      <a href={ns.url}>
                        <samp>{ns.uri}</samp>
                      </a>{' '}
                      ({ns.properties_count} {t('xmp_namespace_properties')})
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  )
}

export default XmpNamespacesIndex
