React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
classList = require('classnames/dedupe')
t = require('../../../lib/string-translation')('de')
RailsForm = require('../../lib/forms/rails-form.cjsx')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')
Modal = require('../../ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollection'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    buttonMargins = {
      marginTop: '5px'
      marginRight: '5px'
    }

    <Modal>

      <div className='ui-modal-head'>
          <a href={get.resource_url} aria-hidden='true'
            className='ui-modal-close' data-dismiss='modal'
            title='Close' type='button'
            style={{position: 'static', float: 'right', paddingTop: '5px'}}>
            <i className='icon-close'></i>
          </a>
        <h3 className='title-l'>{t('resource_select_collection_title')}</h3>
      </div>

      <div className='ui-modal-toolbar top'>
        <div className='ui-search'>
          <RailsForm name='search_collections' action={get.select_collection_url}
              method='get' authToken={authToken} className='dummy'>

            <InputFieldText autocomplete='off' autofocus='autofocus'
              className='ui-search-input block'
              placeholder={t('resource_select_collection_search_placeholder')}
              name='search_term' value={get.search_term} />
            <Button style={buttonMargins} className='button' type='submit' name='search'>
              {t('resource_select_collection_search')}</Button>
            <Button style={buttonMargins} className='button' type='submit' name='clear'>
              {t('resource_select_collection_clear')}</Button>
          </RailsForm>
        </div>
      </div>

      <RailsForm name='select_collections' action={get.add_remove_collection_url}
              method='patch' authToken={authToken} className='dummy' className='save-arcs'>

        <div className='ui-modal-body' style={{maxHeight: 'none'}}>
          {if get.collection_rows.length isnt 0
            <ol className='ui-set-list pbs'>
              {f.map get.collection_rows, (row) ->
                collection = row.collection
                checked = row.contains_media_entry
                <li key={collection.uuid} className='ui-set-list-item'>
                  <label>
                    <input type='hidden'
                      name={('selected_collections[' + collection.uuid + '][]')}
                      value='false'></input>
                    <input className='ui-set-list-input' type='checkbox'
                      name={('selected_collections[' + collection.uuid + '][]')}
                      value='true' defaultChecked={checked}></input>
                    <span className='title'>{collection.title}</span>
                    <span className='owner'>{collection.owner_pretty}</span>
                    <span className='created-at'>{collection.created_at_pretty}</span>
                  </label>
                </li>
              }
            </ol>
          }
          {if get.collection_rows.length is 0 and f.presence(get.search_term)
            <h3 className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
          }
          {if get.collection_rows.length is 0 and not f.presence(get.search_term)
            <h3 className="by-center title-m">{t('resource_select_collection_non_assigned')}</h3>
          }
        </div>

        {if not get.reduced_set and not f.presence(get.search_term)
          <div className="body-upper-limit ui-modal-toolbar bottom try-search-hint">
            <p className="title-xs by-center">{t('resource_select_collection_hint_search')}</p>
          </div>
        }

        {if get.reduced_set
          <div className="body-upper-limit ui-modal-toolbar bottom try-search-hint">
            <p className="title-xs by-center">{t('resource_select_collection_hint_more')}</p>
          </div>
        }

        <div className="ui-modal-footer body-lower-limit">
          <div className="ui-actions">
            <a href={get.resource_url} className="link weak">
              {t('resource_select_collection_cancel')}</a>
            <Button className="primary-button" type='submit'>
              {t('resource_select_collection_save')}</Button>
          </div>
        </div>

      </RailsForm>


    </Modal>