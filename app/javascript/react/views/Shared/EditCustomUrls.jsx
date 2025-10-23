import React from 'react'
import t from '../../../lib/i18n-translate.js'
import PageHeader from '../../ui-components/PageHeader.js'
import RailsForm from '../../lib/forms/rails-form.jsx'

class EditCustomUrls extends React.Component {
  render() {
    const { authToken, get } = this.props
    const { custom_urls_url } = this.props.get

    return (
      <div>
        <PageHeader icon={null} title={t('edit_custom_urls_create_or_transfer')} actions={[]} />
        {!get.confirmation ? (
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
        ) : (
          <div className="bright ui-container pal bordered rounded">
            <div>
              <RailsForm
                name="resource_meta_data"
                action={custom_urls_url}
                method="put"
                authToken={authToken}>
                <input type="hidden" name="custom_url_name" value={get.confirmation.address_id} />
                <input type="hidden" name="confirmation" value={true} />
                <div className="row" style={{ color: '#9a9a9a' }}>
                  <div>
                    <div className="ui-info-box prm mbs">
                      <h2 className="title-l ui-info-box-title mbs">
                        {t('edit_custom_urls_confirmation')}
                      </h2>
                      {'' +
                        t(`custom_urls_flash_transfer_confirmation_${get.confirmation.type}_1`) +
                        '"' +
                        get.confirmation.address_id +
                        '"' +
                        t(`custom_urls_flash_transfer_confirmation_${get.confirmation.type}_2`) +
                        '"' +
                        get.confirmation.from_title +
                        '"' +
                        t(`custom_urls_flash_transfer_confirmation_${get.confirmation.type}_3`) +
                        '"' +
                        get.confirmation.to_title +
                        '"' +
                        t(`custom_urls_flash_transfer_confirmation_${get.confirmation.type}_4`)}
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
        )}
      </div>
    )
  }
}

export default EditCustomUrls
module.exports = EditCustomUrls
