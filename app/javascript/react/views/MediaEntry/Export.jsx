import React from 'react'
import t from '../../../lib/i18n-translate.js'
import Modal from '../../ui-components/Modal.jsx'
import setUrlParams from '../../../lib/set-params-for-url.js'
import getRailsCSRFToken from '../../../lib/rails-csrf-token.js'

class MediaEntryExport extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      active: false,
      checksum: props.get.media_file.checksum || null,
      checksum_verified_at: props.get.media_file.checksum_verified_at || null,
      checksumLoading: false,
      checksumMatch: null
    }
  }

  handleChecksumAction(url) {
    this.setState({ checksumLoading: true, checksumMatch: null })
    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': getRailsCSRFToken(),
        'Accept': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        this.setState({
          checksum: data.checksum,
          checksum_verified_at: data.checksum_verified_at || null,
          checksumLoading: false,
          checksumMatch: data.match != null ? data.match : null
        })
      })
      .catch(() => {
        this.setState({ checksumLoading: false })
      })
  }

  render() {
    const { get } = this.props
    const { checksum, checksum_verified_at, checksumLoading, checksumMatch } = this.state
    let hasPreviews = false
    Object.values(get.media_file.previews).forEach(preview =>
      Object.values(preview).forEach(() => (hasPreviews = true))
    )

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
          className="primary-button"
          rel="noreferrer">
          {t('media_entry_export_download')}
        </a>
      </div>
    ]

    const sectionChecksum = get.checksum_urls && hasOriginal && (
      <div className="ui-export-block">
        <h2 className="title-l ui-resource-title mbs">{t('media_entry_export_checksum')}</h2>
        {!checksum ? (
          <div className="row">
            <div className="col1of2">
              <p>{t('media_entry_export_checksum_generate')}</p>
            </div>
            <div className="col1of2 by-right">
              <button
                className="primary-button"
                disabled={checksumLoading}
                onClick={() => this.handleChecksumAction(get.checksum_urls.generate)}>
                {checksumLoading ? '...' : t('media_entry_export_checksum_generate_btn')}
              </button>
            </div>
          </div>
        ) : (
          <div className="row">
            <div className="col1of3">
              <p style={{ fontFamily: 'monospace', wordBreak: 'break-all' }}>{checksum}</p>
            </div>
            <div className="col1of3 by-center">
              {checksum_verified_at && (
                <p>{new Date(checksum_verified_at).toLocaleDateString()}</p>
              )}
              {checksumMatch != null && (
                <p style={{ color: checksumMatch ? 'green' : 'red', fontWeight: 'bold' }}>
                  {checksumMatch
                    ? t('media_entry_export_checksum_match_ok')
                    : t('media_entry_export_checksum_match_fail')}
                </p>
              )}
            </div>
            <div className="col1of3 by-right">
              <button
                className="primary-button"
                disabled={checksumLoading}
                onClick={() => this.handleChecksumAction(get.checksum_urls.verify)}>
                {checksumLoading
                  ? '...'
                  : checksum_verified_at
                    ? t('media_entry_export_checksum_reverify_btn')
                    : t('media_entry_export_checksum_verify_btn')}
              </button>
            </div>
          </div>
        )}
      </div>
    )

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
            {get.rdf_export_urls.map(({ key, label, url, plain_text_url }) => (
              <tr key={key}>
                <td>
                  <b>{label}</b>
                </td>
                <td style={{ textAlign: 'right' }}>
                  {!!plain_text_url && (
                    <a
                      href={plain_text_url}
                      target="_blank"
                      className="primary-button"
                      rel="noreferrer">
                      <i className="icon-eye" />
                    </a>
                  )}{' '}
                  <a href={url} target="_blank" className="primary-button" rel="noreferrer">
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
          ) : undefined}
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
          ) : undefined}
          {sectionChecksum}
          {hasPreviews
            ? Object.entries(get.media_file.previews).map(([type, preview]) => (
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
                      {Object.entries(preview).map(([key, image]) => (
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
                              style={{ float: 'right' }}
                              rel="noreferrer">
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
}

const forceDownload = url => setUrlParams(url, { download: 'yes' })

export default MediaEntryExport
module.exports = MediaEntryExport
