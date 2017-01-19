React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
classnames = require('classnames')

MetaDataList = require('../../decorators/MetaDataList.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
ResourceShowOverview = require('../../templates/ResourceShowOverview.cjsx')
TabContent = require('../TabContent.cjsx')
SimpleResourceThumbnail = require('../../decorators/SimpleResourceThumbnail.cjsx')
Button = require('../../ui-components/Button.cjsx')
SimpleXhr = require('../../../lib/simple-xhr.coffee')
PageHeader = require('../../ui-components/PageHeader.js')

RailsForm = require('../../lib/forms/rails-form.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')


module.exports = React.createClass
  displayName: 'Shared.EditCustomUrls'

  render: ({authToken, get, title} = @props) ->

    custom_urls_url = @props.get.resource.url + '/custom_urls'

    <div>
      <PageHeader icon={null} title={t('edit_custom_urls_create_or_transfer')} actions={[]} />



      {

        if not get.confirmation
          <div className='bright ui-container pal bordered rounded'>

            <div className='row' style={{color: '#9a9a9a'}}>
              <div className='col1of2'>
                <div className='ui-info-box prm mbs'>
                  <h2 className='title-l ui-info-box-title mbs'>{t('edit_custom_urls_requirements_title')}</h2>
                  {t('edit_custom_urls_requirements_hint')}
                </div>
              </div>
              <div className='col1of2'>
                <div className='ui-info-box plm mbs'>
                  <h2 className='title-l ui-info-box-title mbs'>{t('edit_custom_urls_transfer_title')}</h2>
                  {t('edit_custom_urls_transfer_hint')}
                </div>
              </div>
            </div>

            <hr className='separator mvl' />

            <div>

              <RailsForm name='resource_meta_data' action={custom_urls_url}
                    method='put' authToken={authToken}>

                <h2>{t('edit_custom_urls_preferred_address')}</h2>

                <div style={{paddingRight: '10px'}}>
                  <input type='text' name='custom_url_name' style={{width: '100%'}}></input>
                </div>

                <div className='ui-actions phl pbl mtl'>
                  <a className='link weak' href={custom_urls_url}> {t('edit_custom_urls_cancel')} </a>
                  <button className="primary-button large" type="submit">{t('edit_custom_urls_create_or_transfer')}</button>
                </div>
              </RailsForm>

            </div>
          </div>

        else

          type = get.confirmation.type
          from_title = get.confirmation.from_title
          to_title = get.confirmation.to_title
          address_id = get.confirmation.address_id
          message = '' +
            t('custom_urls_flash_transfer_confirmation_' + type + '_1') +
            '"' + address_id + '"' +
            t('custom_urls_flash_transfer_confirmation_' + type + '_2') +
            '"' + from_title + '"' +
            t('custom_urls_flash_transfer_confirmation_' + type + '_3') +
            '"' + to_title + '"' +
            t('custom_urls_flash_transfer_confirmation_' + type + '_4')


          <div className='bright ui-container pal bordered rounded'>

            <div>

              <RailsForm name='resource_meta_data' action={custom_urls_url}
                    method='put' authToken={authToken}>

                <input type='hidden' name='custom_url_name' value={address_id} />
                <input type='hidden' name='confirmation' value={true} />

                <div className='row' style={{color: '#9a9a9a'}}>
                  <div>
                    <div className='ui-info-box prm mbs'>
                      <h2 className='title-l ui-info-box-title mbs'>{t('edit_custom_urls_confirmation')}</h2>
                      {message}
                    </div>
                  </div>
                </div>

                <div className='ui-actions phl pbl mtl'>
                  <a className='link weak' href={custom_urls_url}> {t('edit_custom_urls_cancel')} </a>
                  <button className="primary-button large" type="submit">{t('edit_custom_urls_transfer')}</button>
                </div>
              </RailsForm>

            </div>
          </div>

      }

    </div>
