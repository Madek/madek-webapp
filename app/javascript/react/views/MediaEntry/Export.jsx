/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const parseUrl = require('url').parse
const t = require('../../../lib/i18n-translate.js')
const Modal = require('../../ui-components/Modal.jsx')
const setUrlParams = require('../../../lib/set-params-for-url.js')

module.exports = React.createClass({
  displayName: 'MediaEntryExport',

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    let hasPreviews = false
    f.each(get.media_file.previews, preview => f.each(preview, entry => (hasPreviews = true)))

    const hasOriginal = get.media_file.original_file_url
    const hasNeither = !hasPreviews && !hasOriginal

    const sectionOriginalFile = hasOriginal && [
      <div className="col1of3" key="1">
        <p>{t('media_entry_export_original_hint')}</p>
      </div>,
      <div className="col1of3 by-center" key="2">
        <p>{get.media_file.extension}</p>
      </div>,
      <div className="col1of3 by-right" key="3">
        <a
          href={forceDownload(get.media_file.original_file_url)}
          target="_blank"
          className="primary-button">
          {t('media_entry_export_download')}
        </a>
      </div>
    ]

    const sectionRdfExport = (
      <div>
        <h2 className="title-l ui-resource-title mbs">
          {t('media_entry_export_rdf_title')} <span>{t('media_entry_export_rdf_title_hint')}</span>
        </h2>
        <p className="font-italic mbs">{t('media_entry_export_rdf_experiment_footnote')}</p>
        <table className="block">
          <thead>
            <tr>
              <td>Typ</td>
              <td />
            </tr>
          </thead>
          <tbody>
            {f.map(get.rdf_export_urls, ({ key, label, url, plain_text_url }) => (
              <tr key={key}>
                <td>
                  <b>{label}</b>
                </td>
                <td style={{ textAlign: 'right' }}>
                  {!!plain_text_url && (
                    <a href={plain_text_url} target="_blank" className="primary-button">
                      <i className="icon-eye" />
                    </a>
                  )}{' '}
                  <a href={url} target="_blank" className="primary-button">
                    <i className="icon-dload" />
                  </a>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    )

    return (
      <Modal widthInPixel="800">
        <div className="ui-modal-head">
          <a
            href={get.url}
            className="ui-modal-close"
            title="Close"
            type="button"
            style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
            <i className="icon-close" />
          </a>
          <h3 className="title-l">{t('media_entry_export_title')}</h3>
        </div>
        <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
          {hasNeither ? (
            <div className="ui-export-block" id="original-meta-data">
              {t('media_entry_export_no_content')}
            </div>
          ) : (
            undefined
          )}
          {hasNeither === false ? (
            <div className="ui-export-block" id="original-meta-data">
              <h2 className="title-l ui-resource-title mbs">{t('media_entry_export_original')}</h2>
              {hasOriginal ? (
                sectionOriginalFile
              ) : (
                <div className="col1of2">
                  <p>{t('media_entry_export_has_no_original')}</p>
                </div>
              )}
            </div>
          ) : (
            undefined
          )}
          {hasPreviews
            ? f.map(get.media_file.previews, (preview, type) => (
                <div key={type} className="align-left bg-light mbm pbs">
                  <h2 className="title-l ui-resource-title mbs">
                    {t(`media_entry_export_subtitle_${type}`)}
                  </h2>
                  <table className="block">
                    <thead>
                      <tr>
                        <td>Auflösung</td>
                        <td>Typ</td>
                        <td />
                      </tr>
                    </thead>
                    <tbody>
                      {f.map(preview, (image, key) => (
                        <tr key={key}>
                          {image.width && image.height ? (
                            <td>{image.width + 'x' + image.height}</td>
                          ) : (
                            <td>-</td>
                          )}
                          <td>{image.extension}</td>
                          <td>
                            <a
                              href={forceDownload(image.url)}
                              target="_blank"
                              className="primary-button"
                              style={{ float: 'right' }}>
                              <i className="icon-dload" />
                            </a>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ))
            : undefined}
          {sectionRdfExport}
        </div>
        <div className="ui-modal-footer">
          <div className="ui-actions">
            <a href={get.url} className="primary-button">
              {t('media_entry_export_close')}
            </a>
          </div>
        </div>
      </Modal>
    )
  }
})

var forceDownload = url => setUrlParams(url, { download: 'yes' })
