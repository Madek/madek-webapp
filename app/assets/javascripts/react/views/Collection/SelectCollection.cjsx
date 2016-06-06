React = require('react')
ReactDOM = require('react-dom')
getRailsCSRFToken = require('../../../lib/rails-csrf-token.coffee')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/string-translation')('de')
RailsForm = require('../../lib/forms/rails-form.cjsx')
InputFieldText = require('../../lib/forms/input-field-text.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
ToggableLink = require('../../ui-components/ToggableLink.cjsx')
Modal = require('../../ui-components/Modal.cjsx')
xhr = require('xhr')
formXhr = require('../../../lib/form-xhr.coffee')
loadXhr = require('../../../lib/load-xhr.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollection'

  getInitialState: () -> {
    mounted: false
    loading: false
    errors: null
    get: null
    searching: false
    searchTerm: ''
    newSets: []
  }

  lastRequest: null

  componentWillMount: () ->
    @setState({searchTerm: @props.boot.search_term})

  componentDidMount: () ->
    @setState({ready: true, mounted: true})

    @setState(loading: true)

    loadXhr(
      {
        method: 'GET'
        url: @props.boot.url + '/select_collection?___sparse={"collection_selection":{}}'
      },
      (result, json) =>
        if result == 'success'
          @setState(loading: false, get: json.collection_selection)
        else
          console.error('Cannot load dialog: ' + JSON.stringify(json))
          @setState({loading: false})
    )

  _onCancel: (event) ->
    if @props.onClose
      event.preventDefault()
      @props.onClose()
      return false
    else
      return true

  _onClickNew: (event) ->
    event.preventDefault()

    trimmed = @state.searchTerm.trim()
    if trimmed.length > 0
      @state.newSets.push(trimmed)
      @setState({newSets: @state.newSets})

    return false

  _onChange: (event) ->
    @setState({searchTerm: event.target.value})

    # if @props.onClose
    @setState({searching: true})

    # TODO: Kill all before!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if @lastRequest
      @lastRequest.abort()

    @lastRequest = formXhr(
      {
        method: 'GET'
        url: @state.get.select_collection_url
        form: @refs.form
      },
      (result, json) =>
        if result == 'success'
          @setState({get: json.collection_selection, searching: false})
    )

  render: ({authToken, get, onClose} = @props) ->

    # TODO: Should this first be rendered with loading false in initial state?
    if @state.loading or (@props.async and not @state.mounted)
      <Modal loading={true}>

      </Modal>
    else

      error = @state.error or get.error
      get = @state.get if @state.get

      alerts = if @state.error
        <div className="ui-alerts" key='alerts'>
          <p className="ui-alert error">{@state.error}</p>
        </div>


      buttonMargins = {
        marginTop: '5px'
        marginRight: '5px'
      }

      showNew = @state.newSets.length > 0
      showEntries = get.collection_rows.length isnt 0

      <Modal loading={false}>

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
            <RailsForm ref='form' name='search_collections' action={get.select_collection_url}
                method='get' authToken={authToken} className='dummy'>

              <input type='text' autoCorrect='off' autoComplete='off' autofocus='autofocus'
                className='ui-search-input block'
                placeholder={t('resource_select_collection_search_placeholder')}
                name='search_term' value={@state.searchTerm}
                onChange={@_onChange}/>
              {
                if not @state.mounted
                  [
                    <Button style={buttonMargins} className='button' type='submit' name='search'>
                      {t('resource_select_collection_search')}</Button>
                    ,
                    <Button style={buttonMargins} className='button' type='submit' name='clear'>
                      {t('resource_select_collection_clear')}</Button>
                  ]
                else
                  <button onClick={@_onClickNew} className="button ui-search-button">Neues Set erstellen</button>
              }
            </RailsForm>
          </div>
        </div>

        <RailsForm name='select_collections' action={get.add_remove_collection_url}
                method='patch' authToken={authToken} className='dummy' className='save-arcs'>

          <div className='ui-modal-body' style={{maxHeight: 'none'}}>
            {if @state.searching and not (showNew or showEntries)
              <Preloader />
            }


            {if showNew or showEntries
              <ol className='ui-set-list pbs'>

                {if showNew
                  f.map @state.newSets, (row, index) ->
                    <li key={'new_' + index} className='ui-set-list-item'>
                      <label>
                        <input type='hidden'
                          name={('new_collections[new_' + index + '][checked]')}
                          value='false'></input>
                        <input type='hidden'
                          name={('new_collections[new_' + index + '][name]')}
                          value={row}></input>
                        <input className='ui-set-list-input' type='checkbox'
                          name={('new_collections[new_' + index + '][checked]')}
                          value='true' defaultChecked={true}></input>
                        <span className='title'>{row}</span>
                        <span className='owner'>{get.current_user.label}</span>
                        <span className='created-at'>{'New'}</span>
                      </label>
                    </li>
                }

                {

                  if @state.searching
                    <Preloader style={{marginTop: '20px'}}/>
                  else if showEntries
                    f.map get.collection_rows, (row) ->
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




            {if get.collection_rows.length is 0 and f.presence(get.search_term) and not @state.searching
              <h3 className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
            }
            {if get.collection_rows.length is 0 and not f.presence(get.search_term) and not @state.searching
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
