React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../lib/string-translation.coffee')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
InputFieldText = require('./lib/forms/input-field-text.cjsx')
Button = require('./ui-components/Button.cjsx')
Icon = require('./ui-components/Icon.cjsx')
classList = require('classnames/dedupe')
Modal = require('./ui-components/Modal.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollection'

  getInitialState: () -> { active: false }

  render: ({authToken, get} = @props) ->

    buttonMargins = {
      marginTop: '5px'
      marginRight: '5px'
    }

    <Modal>

      <div className='ui-modal-head height-consumer'>
        <h3 className='title-l'>{t('media_entry_select_collection_title')}</h3>
      </div>

      <div className='ui-modal-toolbar top height-consumer'>
        <div className='ui-search'>
          <RailsForm name='search_collections' action={get.select_collection_url}
              method='get' authToken={authToken} className='dummy'>

            <InputFieldText autocomplete='off' autofocus='autofocus'
              className='ui-search-input block'
              placeholder={t('media_entry_select_collection_search_placeholder')}
              name='search_term' value={get.search_term} />
            <Button style={buttonMargins} className='button' type='submit' name='search'>
              {t('media_entry_select_collection_search')}</Button>
            <Button style={buttonMargins} className='button' type='submit' name='clear'>
              {t('media_entry_select_collection_clear')}</Button>
          </RailsForm>
        </div>
      </div>

      <RailsForm name='select_collections' action={get.add_to_collection_url}
              method='patch' authToken={authToken} className='dummy' className='save-arcs'>

        <div className='ui-modal-body'>
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
                    <span className='owner'>{collection.owner}</span>
                    <span className='created-at'>{collection.created_at}</span>
                  </label>
                </li>
              }
            </ol>
          }
          {if get.collection_rows.length is 0 and f.presence(get.search_term)
            <h3 className="by-center title-m">{t('media_entry_select_collection_non_found')}</h3>
          }
          {if get.collection_rows.length is 0 and not f.presence(get.search_term)
            <h3 className="by-center title-m">{t('media_entry_select_collection_non_assigned')}</h3>
          }
        </div>

        {if not get.reduced_set and not f.presence(get.search_term)
          <div className="body-upper-limit ui-modal-toolbar bottom try-search-hint">
            <p className="title-xs by-center">{t('media_entry_select_collection_hint_search')}</p>
          </div>
        }

        {if get.reduced_set
          <div className="body-upper-limit ui-modal-toolbar bottom try-search-hint">
            <p className="title-xs by-center">{t('media_entry_select_collection_hint_more')}</p>
          </div>
        }

        <div className="ui-modal-footer body-lower-limit height-consumer">
          <div className="ui-actions">
            <a href={get.media_entry_url} className="link weak">
              {t('media_entry_select_collection_cancel')}</a>
            <Button className="primary-button" type='submit'>
              {t('media_entry_select_collection_save')}</Button>
          </div>
        </div>

      </RailsForm>


    </Modal>
