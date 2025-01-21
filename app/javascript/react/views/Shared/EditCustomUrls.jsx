/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import t from '../../../lib/i18n-translate.js'
import PageHeader from '../../ui-components/PageHeader.js'
import RailsForm from '../../lib/forms/rails-form.jsx'

module.exports = createReactClass({
  displayName: 'Shared.EditCustomUrls',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const { custom_urls_url } = this.props.get

    return (
      <div>
        <PageHeader icon={null} title={t('edit_custom_urls_create_or_transfer')} actions={[]} />
        {(() => {
          if (!get.confirmation) {
            return (
              <div className="bright ui-container pal bordered rounded">
                <div className="row" style={{ color: '#9a9a9a' }}>
                  <div className="col1of2">
                    <div className="ui-info-box prm mbs">
                      <h2 className="title-l ui-info-box-title mbs">
                        {t('edit_custom_urls_requirements_title')}
                      </h2>
                      {t('edit_custom_urls_requirements_hint')}
                    </div>
                  </div>
                  <div className="col1of2">
                    <div className="ui-info-box plm mbs">
                      <h2 className="title-l ui-info-box-title mbs">
                        {t('edit_custom_urls_transfer_title')}
                      </h2>
                      {t('edit_custom_urls_transfer_hint')}
                    </div>
                  </div>
                </div>
                <hr className="separator mvl" />
                <div>
                  <RailsForm
                    name="resource_meta_data"
                    action={custom_urls_url}
                    method="put"
                    authToken={authToken}>
                    <h2>{t('edit_custom_urls_preferred_address')}</h2>
                    <div style={{ paddingRight: '10px' }}>
                      <input type="text" name="custom_url_name" style={{ width: '100%' }} />
                    </div>
                    <div className="ui-actions phl pbl mtl">
                      <a className="link weak" href={custom_urls_url}>
                        {' '}
                        {t('edit_custom_urls_cancel')}{' '}
                      </a>
                      <button className="primary-button large" type="submit">
                        {t('edit_custom_urls_create_or_transfer')}
                      </button>
                    </div>
                  </RailsForm>
                </div>
              </div>
            )
          } else {
            const { type } = get.confirmation
            const { from_title } = get.confirmation
            const { to_title } = get.confirmation
            const { address_id } = get.confirmation
            const message =
              '' +
              t(`custom_urls_flash_transfer_confirmation_${type}_1`) +
              '"' +
              address_id +
              '"' +
              t(`custom_urls_flash_transfer_confirmation_${type}_2`) +
              '"' +
              from_title +
              '"' +
              t(`custom_urls_flash_transfer_confirmation_${type}_3`) +
              '"' +
              to_title +
              '"' +
              t(`custom_urls_flash_transfer_confirmation_${type}_4`)

            return (
              <div className="bright ui-container pal bordered rounded">
                <div>
                  <RailsForm
                    name="resource_meta_data"
                    action={custom_urls_url}
                    method="put"
                    authToken={authToken}>
                    <input type="hidden" name="custom_url_name" value={address_id} />
                    <input type="hidden" name="confirmation" value={true} />
                    <div className="row" style={{ color: '#9a9a9a' }}>
                      <div>
                        <div className="ui-info-box prm mbs">
                          <h2 className="title-l ui-info-box-title mbs">
                            {t('edit_custom_urls_confirmation')}
                          </h2>
                          {message}
                        </div>
                      </div>
                    </div>
                    <div className="ui-actions phl pbl mtl">
                      <a className="link weak" href={custom_urls_url}>
                        {' '}
                        {t('edit_custom_urls_cancel')}{' '}
                      </a>
                      <button className="primary-button large" type="submit">
                        {t('edit_custom_urls_transfer')}
                      </button>
                    </div>
                  </RailsForm>
                </div>
              </div>
            )
          }
        })()}
      </div>
    )
  }
})
