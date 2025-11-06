import React from 'react'
import PageContent from '../PageContent.jsx'
import TabContent from '../TabContent.jsx'
import PageHeader from '../../ui-components/PageHeader.jsx'
import t from '../../../lib/i18n-translate.js'
import SelectingTextarea from '../../lib/forms/SelectingTextarea.jsx'

class Share extends React.Component {
  _onClick = event => {
    event.preventDefault()
    if (this.props.onClose) {
      return this.props.onClose()
    }
  }

  _typeUnderscore() {
    const { get } = this.props
    if (get.type === 'MediaEntry') {
      return 'media_entry'
    } else if (get.type === 'Collection') {
      return 'collection'
    } else {
      throw `Unexpected type: ${get.type}`
    }
  }

  _primaryCustomUrl() {
    return this.props.get.primary_custom_url
  }

  _uuidUrl() {
    return this.props.get.uuid_url
  }

  renderContent(get) {
    return (
      <div>
        <div className="ui-info-box prm mbs">
          <h2 className="title-l ui-info-box-title mbs">{t('share_uuid_url_subtitle')}</h2>
          <div>{t(`share_uuid_url_hint_${this._typeUnderscore()}`)}</div>
          <div>{t('share_uuid_url_hint_exporter')}</div>
          <div>
            <input
              type="text"
              className="mtm"
              value={this._uuidUrl()}
              onChange={() => {}}
              style={{ width: '100%' }}
            />
          </div>
        </div>
        {get.type === 'MediaEntry' && (
          <div className="ui-info-box prm mbs mtl">
            <h2 className="title-l ui-info-box-title mbs">{t('share_embed_hint_subtitle')}</h2>
            <div className="mbm">{t('share_embed_hint_oembed')}</div>
            <div className="mbm">{t('share_embed_hint_iframe')}</div>
            <details open>
              <summary>{t('share_embed_hint_iframe_code')}</summary>
              <SelectingTextarea className="code block pas">
                {get.embed_html_code}
              </SelectingTextarea>
            </details>
          </div>
        )}
        <div className="ui-info-box prm mbs mtl">
          <h2 className="title-l ui-info-box-title mbs">{t('share_custom_url_subtitle')}</h2>
          {t(`share_custom_url_hint_${this._typeUnderscore()}`)}
          {get.primary_custom_url ? (
            <div>
              <input
                className="mtm"
                type="text"
                value={this._primaryCustomUrl()}
                onChange={() => {}}
                style={{ width: '100%' }}
              />
            </div>
          ) : (
            <div>
              <input
                disabled={true}
                className="mtm"
                type="text"
                defaultValue={t('share_custom_url_none_available')}
                style={{ width: '100%', color: '#999', textAlign: 'center' }}
              />
            </div>
          )}
        </div>{' '}
      </div>
    )
  }

  render() {
    const { get, fullPage } = this.props
    if (fullPage) {
      return (
        <PageContent>
          <PageHeader title={get.title} fa="fa fa-share" />
          <TabContent>
            <div className="bright pal rounded-bottom rounded-top-right ui-container">
              <div className="ui-container">
                {this.renderContent(get)}
                <div className="ui-actions mtl">
                  <a href={get.resource_url} className="button">
                    {t(`share_back_to_${this._typeUnderscore()}`)}
                  </a>
                </div>
              </div>
            </div>
          </TabContent>
        </PageContent>
      )
    } else {
      return (
        <div>
          <div className="ui-modal-head">
            <a
              href={get.resource_url}
              aria-hidden="true"
              onClick={this._onClick}
              className="ui-modal-close"
              data-dismiss="modal"
              title="Close"
              type="button"
              style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
              <i className="icon-close" />
            </a>
            <h3 className="title-l">{t(`share_title_${this._typeUnderscore()}`)}</h3>
          </div>
          <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
            {this.renderContent(get)}
          </div>
          <div className="ui-modal-footer">
            <div className="ui-actions">
              <a
                href={get.resource_url}
                aria-hidden="true"
                className="link weak"
                onClick={this._onClick}
                data-dismiss="modal">
                {t('share_close')}
              </a>
            </div>
          </div>
        </div>
      )
    }
  }
}

export default Share
module.exports = Share
