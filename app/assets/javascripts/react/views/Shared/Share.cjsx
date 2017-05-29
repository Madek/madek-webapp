React = require('react')
ReactDOM = require('react-dom')
PageContent = require('../PageContent.cjsx')
TabContent = require('../TabContent.cjsx')
PageHeader = require('../../ui-components/PageHeader.js')
Modal = require('../../ui-components/Modal.cjsx')
t = require('../../../lib/string-translation')('de')

module.exports = React.createClass
  displayName: 'Shared.Share'

  _onClick: (event) ->
    event.preventDefault()
    if @props.onClose
      @props.onClose()

  _typeUnderscore: () ->
    get = @props.get
    if get.type == 'MediaEntry'
      'media_entry'
    else if get.type == 'Collection'
      'collection'
    else
      throw 'Unexpected type: ' + get.type


  render: ({authToken, get, fullPage} = @props) ->

    if fullPage
      <PageContent>
        <PageHeader title={get.title} fa='fa fa-share'/>
        <TabContent>
          <div className='bright pal rounded-bottom rounded-top-right ui-container'>
            <div className='ui-container'>
              {@renderContent(get)}
              <div className='ui-actions mtl'>
                <a href={get.resource_url} className='button'>
                  {t('share_back_to_' + @_typeUnderscore())}
                </a>
              </div>

            </div>
          </div>
        </TabContent>
      </PageContent>
    else

      <div>
        <div className='ui-modal-head'>
          <a href={get.resource_url} aria-hidden='true'
            onClick={@_onClick}
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'
            style={{position: 'static', float: 'right', paddingTop: '5px'}}>
            <i className='icon-close'></i>
          </a>
          <h3 className='title-l'>{t('share_title_' + @_typeUnderscore())}</h3>
        </div>

        <div className='ui-modal-body' style={{maxHeight: 'none'}}>
          {@renderContent(get)}
        </div>

        <div className='ui-modal-footer'>
          <div className='ui-actions'>
            <a href={get.resource_url} aria-hidden='true' className='link weak'
              onClick={@_onClick}
              data-dismiss='modal'>{t('share_close')}</a>
          </div>
        </div>

      </div>

  _primaryCustomUrl: () ->
    @props.get.primary_custom_url

  _uuidUrl: () ->
    @props.get.uuid_url


  renderContent: (get) ->

    <div>
      <div className='ui-info-box prm mbs'>
        <h2 className='title-l ui-info-box-title mbs'>
          {t('share_uuid_url_subtitle')}
        </h2>
        {t('share_uuid_url_hint')}
        <div>
          <input className='mtm' type='text'
            value={@_uuidUrl()}
            onChange={() ->}
            style={{width: '100%'}} />
        </div>
      </div>
      <div className='ui-info-box prm mbs mtl'>
        <h2 className='title-l ui-info-box-title mbs'>
          {t('share_custom_url_subtitle')}
        </h2>
        {t('share_custom_url_hint')}
        {
          if get.primary_custom_url
            <div>
              <input className='mtm' type='text'
                value={@_primaryCustomUrl()}
                onChange={() ->}
                style={{width: '100%'}} />
            </div>
          else
            <div>
              <input disabled className='mtm' type='text' defaultValue={t('share_custom_url_none_available')}
                style={{width: '100%', color: '#999', textAlign: 'center'}} />
            </div>
        }
      </div>
    </div>
