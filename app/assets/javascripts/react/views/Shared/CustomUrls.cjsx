React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
classnames = require('classnames')

Moment = require('moment')

MetaDataList = require('../../decorators/MetaDataList.cjsx')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
ResourceShowOverview = require('../../templates/ResourceShowOverview.cjsx')
TabContent = require('../TabContent.cjsx')
SimpleResourceThumbnail = require('../../decorators/SimpleResourceThumbnail.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
HeaderPrimaryButton = require('../HeaderPrimaryButton.cjsx')
Button = require('../../ui-components/Button.cjsx')

RailsForm = require('../../lib/forms/rails-form.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')



module.exports = React.createClass
  displayName: 'Shared.CustomUrls'

  _renderCustomUrl: (custom_url) ->

    address_name = custom_url.uuid
    created_at = Moment(custom_url.created_at).calendar()
    creator = custom_url.creator.name + ' [' + custom_url.creator.login + ']'
    type = if custom_url['primary?'] then t('edit_custom_urls_state_primary') else t('edit_custom_urls_state_transfer')

    if not custom_url['primary?']
      setPrimary =
        <RailsForm name='resource_meta_data' action={@props.get.resource.url + '/set_primary_custom_url/' + custom_url.uuid}
              method='patch' authToken={@props.authToken}>
          <button className='button' type='submit'>{t('edit_custom_urls_set_primary')}</button>
        </RailsForm>

    type_to_path = {
      'Collection': 'sets'
      'MediaEntry': 'entries'
    }

    link = '/' + type_to_path[@props.get.resource.type] + '/' + address_name

    <tr key={custom_url.uuid}>
      <td><a href={link}>{address_name}</a></td>
      <td>{created_at}</td>
      <td>{creator}</td>
      <td>{type}</td>
      <td style={{textAlign: 'right'}}>{setPrimary}</td>
    </tr>


  render: ({get, title} = @props) ->

    resource = get.resource

    title = t('custom_urls_title') + '"' + resource.title + '"'

    headerButton = <HeaderPrimaryButton key={'new_custom_url'}
      icon={null} text={t('custom_urls_new')}
      href={resource.url + '/custom_urls/edit'} />


    <div>
      <PageHeader icon={null} title={title} actions={[headerButton]} />

      <div className='bright ui-container pal bordered rounded'>

        <div className='row' style={{color: '#9a9a9a'}}>
          <div className='col1of2'>
            <div className='ui-info-box prm mbs'>
              <h2 className='title-l ui-info-box-title mbs'>{t('custom_urls_primary_title')}</h2>
              {t('custom_urls_primary_hint')}
            </div>
          </div>
          <div className='col1of2'>
            <div className='ui-info-box plm mbs'>
              <h2 className='title-l ui-info-box-title mbs'>{t('custom_urls_canonical_title')}</h2>
              {t('custom_urls_canonical_hint')}
            </div>
          </div>
        </div>

        <hr className='separator mvl' />

        <div>
          <h2 className='title-l mbs'>{t('custom_urls_manage_address_title')}</h2>

          {
            if f.isEmpty(get.custom_urls)
              <div style={{textAlign: 'center', paddingTop: '30px'}}>{t('custom_urls_no_addresses_defined')}</div>

            else
              <table className='ui-rights-group bordered block'>
                <thead>
                  <tr>
                    <td style={{width: '30%'}}>{t('custom_urls_table_header_address')}</td>
                    <td style={{width: '20%'}}>{t('custom_urls_table_header_date')}</td>
                    <td style={{width: '20%'}}>{t('custom_urls_table_header_created_by')}</td>
                    <td style={{width: '10%'}}>{t('custom_urls_table_header_type')}</td>
                    <td style={{width: '20%', textAlign: 'right'}}>{t('custom_urls_table_header_actions')}</td>
                  </tr>
                </thead>
                <tbody>
                  {
                    f.map(f.sortBy(get.custom_urls, 'created_at').reverse(), (custom_url) =>
                      @_renderCustomUrl(custom_url)
                    )
                  }
                </tbody>
              </table>
          }

          <div className='ui-actions phl pbl mtl'>
            <a className='button' href={@props.get.resource.url}> {t('edit_custom_urls_back')} </a>
          </div>

        </div>

      </div>
    </div>
