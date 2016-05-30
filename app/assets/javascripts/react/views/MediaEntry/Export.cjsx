React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/string-translation')('de')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
Modal = require('../../ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'MediaEntryExport'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    hasPreviews = false
    f.each get.media_file.previews, (preview) ->
      f.each preview, (entry) ->
        hasPreviews = true

    hasOriginal = get.media_file.original_file_url
    hasNeither = not hasPreviews and not hasOriginal

    <Modal widthInPixel='800'>

      <div className='ui-modal-head'>
        <a href={get.url} aria-hidden='true'
          className='ui-modal-close' data-dismiss='modal'
          title='Close' type='button'
          style={{position: 'static', float: 'right', paddingTop: '5px'}}>
          <i className='icon-close'></i>
        </a>
        <h3 className='title-l'>{t('media_entry_export_title')}</h3>
      </div>

      <div className='ui-modal-body' style={{maxHeight: 'none'}}>

        {
          if hasNeither
            <div className="ui-export-block" id="original-meta-data">
              {t('media_entry_export_no_content')}
            </div>
        }


        {
          if hasNeither == false
            <div className="ui-export-block" id="original-meta-data">
              <h2 className="title-l ui-resource-title"
                style={{marginTop: '0px', marginLeft: '0px', marginBottom: '20px'}}>
                {t('media_entry_export_original')}
              </h2>
              {
                if hasOriginal
                  [
                    <div className="col1of2">
                      <p>
                        {t('media_entry_export_original_hint')}
                      </p>
                    </div>
                    ,
                    <div className="col1of2 by-right">
                      <a href={get.media_file.original_file_url} aria-hidden='true'
                        className='primary-button' data-dismiss='modal'>
                        {t('media_entry_export_download')}
                      </a>
                    </div>
                  ]
                else
                  <div className="col1of2">
                    <p>
                      {t('media_entry_export_has_no_original')}
                    </p>
                  </div>
              }
            </div>

        }

        {
          if hasPreviews
            f.map get.media_file.previews, (preview, type) ->
              <div key={type} className="align-left bg-light sg-canvas sg-modifier">
                <h2 className="title-l ui-resource-title" style={{marginTop: '40px', marginLeft: '0px', marginBottom: '20px'}}>
                  {
                    t('media_entry_export_subtitle_' + type)
                  }
                </h2>
                <table className="block">
                  <thead>
                    <tr>
                      <td>Auflösung</td>
                      <td>Typ</td>
                      <td></td>
                    </tr>
                  </thead>
                  <tbody>
                    {
                      f.map preview, (image, key) ->
                        <tr key={key}>
                          {
                            if image.width and image.height
                              <td>{image.width + 'x' + image.height}</td>
                            else
                              <td>-</td>
                          }
                          <td>{image.extension}</td>
                          <td>
                            <a href={image.url} aria-hidden='true' target='_blank'
                              className='primary-button' style={{float: 'right'}} data-dismiss='modal'>
                              <i className="icon-dload"></i>
                            </a>
                          </td>
                        </tr>
                    }
                  </tbody>
                </table>
              </div>
        }



      </div>

      <div className='ui-modal-footer'>
        <div className='ui-actions'>
          <a href={get.url} aria-hidden='true'
            className='primary-button' data-dismiss='modal'>
            {t('media_entry_export_close')}
          </a>
        </div>
      </div>

    </Modal>
