React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
Moment = require('moment')

PageHeader = require('../../ui-components/PageHeader.js')
HeaderPrimaryButton = require('../HeaderPrimaryButton.cjsx')
Button = require('../../ui-components/Button.cjsx')
RailsForm = require('../../lib/forms/rails-form.cjsx')


module.exports = React.createClass
  displayName: 'Shared.CustomUrls'


  _renderCustomUrlRow: (address_name, created_at_timestamp, creator_name, creator_login, is_primary, action_url, resource_type, auth_token) ->

    created_at = Moment(created_at_timestamp).calendar()
    creator = creator_name + ' [' + creator_login + ']'
    type = if is_primary then t('edit_custom_urls_state_primary') else t('edit_custom_urls_state_transfer')

    if not is_primary
      setPrimary =
        <RailsForm name='resource_meta_data' action={action_url}
              method='patch' authToken={auth_token}>
          <button className='button' type='submit'>{t('edit_custom_urls_set_primary')}</button>
        </RailsForm>

    type_to_path = {
      'Collection': 'sets'
      'MediaEntry': 'entries'
    }

    link = '/' + type_to_path[resource_type] + '/' + address_name

    <tr key={address_name}>
      <td><a href={link}>{address_name}</a></td>
      <td>{created_at}</td>
      <td>{creator}</td>
      <td>{type}</td>
      <td style={{textAlign: 'right'}}>{setPrimary}</td>
    </tr>


  _renderCustomUrl: (custom_url) ->
    @_renderCustomUrlRow(
      custom_url.uuid,
      custom_url.created_at,
      custom_url.creator.name,
      custom_url.creator.login,
      custom_url['primary?'],
      @props.get.resource.url + '/set_primary_custom_url/' + custom_url.uuid,
      @props.get.resource.type,
      @props.authToken
    )

  _renderUuidRow: (resource, creator, any_primary_address) ->
    @_renderCustomUrlRow(
      resource.uuid,
      resource.created_at,
      creator.name,
      creator.login,
      not any_primary_address,
      resource.url + '/set_primary_custom_url/' + resource.uuid,
      resource.type,
      @props.authToken
    )

  _anyPrimaryAddress: (custom_urls) ->
    not f.isEmpty(f.filter(custom_urls, { 'primary?': true }))


  render: ({get, title} = @props) ->

    resource = get.resource

    title = t('custom_urls_title') + '"' + resource.title + '"'

    headerButton = <HeaderPrimaryButton key={'new_custom_url'}
      icon={null} text={t('custom_urls_new')}
      href={resource.url + '/custom_urls/edit'} />

    backText = t('edit_custom_urls_back_to_' + f.kebabCase(@props.get.type).replace('-', '_'))

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
                  @_renderUuidRow(
                    get.resource,
                    get.resource_creator,
                    @_anyPrimaryAddress(get.custom_urls)
                  )
                }
                {
                  f.map(f.sortBy(get.custom_urls, 'created_at').reverse(), (custom_url) =>
                    @_renderCustomUrl(custom_url)
                  )
                }
              </tbody>
            </table>

          <div className='ui-actions phl pbl mtl'>
            <a className='button' href={@props.get.resource.url}> {backText} </a>
          </div>

        </div>

      </div>
    </div>
