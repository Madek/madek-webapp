import React from 'react'
import t from '../../../lib/i18n-translate.js'
import Modal from '../../ui-components/Modal.jsx'
import setUrlParams from '../../../lib/set-params-for-url.js'
import Moment from 'moment'
import currentLocale from '../../../lib/current-locale.js'

class MediaEntryExport extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      active: false,
      checksum: props.get.media_file.checksum,
      checksumVerifiedAt: props.get.media_file.checksum_verified_at,
      checksumMatch: null,
      isGenerating: false,
      isVerifying: false,
      error: null
    }
  }

  handleGenerateChecksum = async () => {
    const { get } = this.props
    if (!get.checksum_urls || !get.checksum_urls.generate) return

    this.setState({ isGenerating: true, error: null })

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')
      const response = await fetch(get.checksum_urls.generate, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken ? csrfToken.content : ''
        }
      })

      if (!response.ok) throw new Error('Failed to generate checksum')

      const data = await response.json()
      this.setState({
        checksum: data.checksum,
        checksumVerifiedAt: new Date(),
        isGenerating: false,
        checksumMatch: null
      })
    } catch (err) {
      this.setState({ error: err.message, isGenerating: false })
    }
  }

  handleVerifyChecksum = async () => {
    const { get } = this.props
    if (!get.checksum_urls || !get.checksum_urls.verify) return

    this.setState({ isVerifying: true, error: null })

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')
      const response = await fetch(get.checksum_urls.verify, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken ? csrfToken.content : ''
        }
      })

      if (!response.ok) throw new Error('Failed to verify checksum')

      const data = await response.json()
      this.setState({
        checksum: data.checksum,
        checksumVerifiedAt: data.checksum_verified_at,
        checksumMatch: data.match,
        isVerifying: false
      })
    } catch (err) {
      this.setState({ error: err.message, isVerifying: false })
    }
  }

  render() {
    const { get } = this.props
    let hasPreviews = false
    Object.values(get.media_file.previews).forEach(preview =>
      Object.values(preview).forEach(() => (hasPreviews = true))
    )

    const hasOriginal = get.media_file.original_file_url
    const hasNeither = !hasPreviews && !hasOriginal

    Moment().locale(currentLocale())

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

    const { checksum, checksumVerifiedAt, checksumMatch, isGenerating, isVerifying, error } =
      this.state

    const sectionChecksum = (
      <div className="ui-export-block">
        <h2 className="title-l ui-resource-title mbs">{t('media_entry_export_checksum_title')}</h2>
        {checksumMatch && (
          <div className="success ui-alert mbm">{t('media_entry_export_checksum_match')}</div>
        )}
        {checksumMatch === false && (
          <div className="error ui-alert mbm">{t('media_entry_export_checksum_mismatch')}</div>
        )}
        {error && (
          <div className="error ui-alert mbm">
            {t('media_entry_export_checksum_error')}: {error}
          </div>
        )}
        <div className="col2of5">
          {checksum ? `md5: ${checksum}` : t('media_entry_export_checksum_empty')}
        </div>
        <div className="col1of5 by-center">
          {checksum ? (
            checksumVerifiedAt ? (
              <span>{Moment(checksumVerifiedAt).format('L')}</span>
            ) : (
              '?'
            )
          ) : (
            'md5'
          )}
        </div>
        <div className="col2of5 by-right">
          {checksum && (
            <button
              onClick={this.handleVerifyChecksum}
              disabled={isGenerating || isVerifying || !checksum}
              className="primary-button"
              type="button">
              {isVerifying
                ? t('media_entry_export_checksum_verifying')
                : t('media_entry_export_checksum_verify')}
            </button>
          )}
          {(!checksum || checksumMatch === false) && (
            <button
              onClick={this.handleGenerateChecksum}
              disabled={isGenerating || isVerifying}
              className="primary-button mls"
              type="button">
              {isGenerating
                ? t('media_entry_export_checksum_generating')
                : t('media_entry_export_checksum_generate')}
            </button>
          )}
        </div>
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
          {hasOriginal && sectionChecksum}
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
