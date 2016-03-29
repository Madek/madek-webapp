React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../lib/string-translation.coffee')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
InputFieldText = require('./lib/forms/input-field-text.cjsx')
Button = require('./ui-components/Button.cjsx')
Modal = require('./ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'EditCollectionCover'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->
    <Modal widthInPixel='800'>

      <RailsForm name='resource_meta_data' action={get.submit_url}
            method='put' authToken={authToken}>

        <div className='ui-modal-head'>
          <a href={get.cancel_url} aria-hidden='true'
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'>
            <i className='icon-close'></i>
          </a>
          <h3 className='title-l'>{t('collection_edit_cover_title')}</h3>
        </div>

        <div className='ui-modal-body'>
          <div className='ui-resources-table'>
            <div className='ui-resources-table'>
              <table className='block'>
                <thead>
                  <tr>
                    <td className='ui-resources-table-selection'>{t('collection_edit_cover_h_selection')}</td>
                    <td title='Titel'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_title')}</span>
                    </td>
                    <td title='Untertitel'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_subtitle')}</span>
                    </td>
                    <td title='Autor/in'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_author')}</span>
                    </td>
                    <td title='Datierung'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_date')}</span>
                    </td>
                    <td title='Schlagworte'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_keywords')}</span>
                    </td>
                    <td title='Rechteinhaber'>
                      <span className='ui-resources-table-cell-content'>{t('collection_edit_cover_h_responsible')}</span>
                    </td>
                  </tr>
                </thead>
                <tbody>
                  {f.map get.media_entries_presenter.resources, (resource) ->

                    cover = get.cover_id is resource.uuid

                    <tr key={resource.uuid}>
                      <td className='ui-resources-table-selection'>
                        <label>
                          <input defaultChecked={cover} name='cover' type='radio' value={resource.uuid}></input>
                          <img className='ui-thumbnail micro' src={resource.image_url}></img>
                        </label>
                      </td>
                      <td data-name='title' title=''>
                        <span className='ui-resources-table-cell-content'>{resource.title}</span>
                      </td>
                      <td data-name='subtitle' title=''>
                        <span className='ui-resources-table-cell-content'>{resource.subtitle}</span>
                      </td>
                      <td data-name='author' title=''>
                        <span className='ui-resources-table-cell-content'>{resource.authors_pretty}</span>
                      </td>
                      <td data-name='portrayed object dates' title='null'>{resource.created_at_pretty}</td>
                      <td data-name='keywords' title=''>
                        <span className='ui-resources-table-cell-content'>{resource.keywords_pretty}</span>
                      </td>
                      <td data-name='copyright notice' title=''>
                        <span className='ui-resources-table-cell-content'>{resource.responsible.name}</span>
                      </td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div className='ui-modal-footer'>
          <div className='ui-actions'>
            <a href={get.cancel_url} aria-hidden='true'
              className='link weak' data-dismiss='modal'>
              {t('collection_edit_cover_cancel')}
            </a>
            <button className='primary-button' type='submit'>{t('collection_edit_cover_save')}</button>
          </div>
        </div>

      </RailsForm>
    </Modal>
