React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/string-translation')('de')
RailsForm = require('../../lib/forms/rails-form.cjsx')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
Modal = require('../../ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'Collection.ResourceSelection'
  propTypes:
    type: React.PropTypes.oneOf(['checkbox', 'radio'])

  getInitialState: () -> { active: false }

  render: ({authToken, get, type} = @props) ->

    <Modal widthInPixel='800'>

      <RailsForm name='resource_meta_data' action={get.submit_url}
            method='put' authToken={authToken}>

        <div className='ui-modal-head'>
          <a href={get.cancel_url} aria-hidden='true'
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'
            style={{position: 'static', float: 'right', paddingTop: '5px'}}>
            <i className='icon-close'></i>
          </a>
          <h3 className='title-l'>{get.i18n.title}</h3>
        </div>

        <div className='ui-modal-body' style={{maxHeight: 'none'}}>
          <div className='ui-resources-table'>
            <div className='ui-resources-table'>
              <table className='block'>
                <thead>
                  <tr>
                    <td className='ui-resources-table-selection'>{get.i18n.h_selection}</td>
                    <td title='Titel'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_title}</span>
                    </td>
                    <td title='Untertitel'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_subtitle}</span>
                    </td>
                    <td title='Autor/in'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_author}</span>
                    </td>
                    <td title='Datierung'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_date}</span>
                    </td>
                    <td title='Schlagworte'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_keywords}</span>
                    </td>
                    <td title='Rechteinhaber'>
                      <span className='ui-resources-table-cell-content'>{get.i18n.h_responsible}</span>
                    </td>
                  </tr>
                </thead>
                <tbody>
                  {f.map get.child_presenters.resources, (resource) ->

                    checked = get.uuid_to_checked_hash[resource.uuid]

                    <tr key={resource.uuid}>
                      <td className='ui-resources-table-selection'>

                        {if type == 'checkbox'
                          <label>
                            <input type='hidden' name={('resource_selections[][id]')} value={resource.uuid}></input>
                            <input type='hidden' name={('resource_selections[][type]')} value={resource.type}></input>
                            <input className='ui-set-list-input' type='checkbox'
                              name={('resource_selections[][selected]')} value='true' defaultChecked={checked}></input>
                            <img className='ui-thumbnail micro' src={resource.image_url}></img>
                          </label>
                        else if type == 'radio'
                          <label>
                            <input defaultChecked={checked} name='selected_resource' type='radio' value={resource.uuid}></input>
                            <img className='ui-thumbnail micro' src={resource.image_url}></img>
                          </label>
                        else null}

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
                      <td data-name='portrayed object dates' title='null'>{resource.portrayed_object_date_pretty}</td>
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
              {get.i18n.cancel}
            </a>
            <FormButton text={get.i18n.save} />
          </div>
        </div>

      </RailsForm>
    </Modal>
