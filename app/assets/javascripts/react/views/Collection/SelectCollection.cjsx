React = require('react')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
t = require('../../../lib/i18n-translate.js')
RailsForm = require('../../lib/forms/rails-form.cjsx')
FormButton = require('../../ui-components/FormButton.cjsx')
ToggableLink = require('../../ui-components/ToggableLink.cjsx')
Modal = require('../../ui-components/Modal.cjsx')
xhr = require('xhr')
formXhr = require('../../../lib/form-xhr.coffee')
loadXhr = require('../../../lib/load-xhr.coffee')
Preloader = require('../../ui-components/Preloader.cjsx')
Button = require('../../ui-components/Button.cjsx')
Icon = require('../../ui-components/Icon.cjsx')
SelectCollectionDialog = require('./SelectCollectionDialog.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollection'

  getInitialState: () -> {
    mounted: false
    searchTerm: ''
    searching: false
    newSets: []
    get: null
    errors: null
  }

  # TODO Potential problem (class variables).
  lastRequest: null
  sendTimeoutRef: null

  componentWillMount: () ->
    @setState(get: @props.get, searchTerm: @props.get.search_term)

  componentDidMount: () ->
    @setState(mounted: true)

  _onChange: (event) ->
    @setState({searchTerm: event.target.value})
    @setState({searching: true})

    if @sendTimeoutRef != null
      return

    @sendTimeoutRef = setTimeout(
      () =>

        @sendTimeoutRef = null

        if @lastRequest
          @lastRequest.abort()

        @lastRequest = formXhr(
          {
            method: 'GET'
            url: @_requestUrl()
            form: @refs.form
          },
          (result, json) =>
            return unless @isMounted()
            if result == 'success'
              @setState({get: json.collection_selection, searching: false})
        )
      ,
      500
    )

  _requestUrl: () ->
    @props.get.select_collection_url


  _onClickNew: (event) ->
    event.preventDefault()

    if @state.searchTerm
      trimmed = @state.searchTerm.trim()
      if trimmed.length > 0
        @state.newSets.push(trimmed)
        @setState({newSets: @state.newSets})

    return false




  render: ({authToken, get, onClose} = @props) ->

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

    hasNew = @state.newSets.length > 0
    hasResultEntries = get.collection_rows.length isnt 0


    _search =
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
                <Button key={'search_button'} style={buttonMargins} className='button' type='submit' name='search'>
                  {t('resource_select_collection_search')}</Button>
                ,
                <Button key={'clear_button'} style={buttonMargins} className='button' type='submit' name='clear'>
                  {t('resource_select_collection_clear')}</Button>
              ]
            else
              <button onClick={@_onClickNew} className="button ui-search-button">Neues Set erstellen</button>
          }
        </RailsForm>
      </div>



    _content = [ ]

    if @state.searching and not (hasNew or hasResultEntries)
      _content.push(
        <Preloader key='content1' />
      )


    if hasNew or hasResultEntries
      _content.push(
        <ol key='content2' className='ui-set-list pbs'>

          {
            if hasNew
              f.map @state.newSets, (row, index) ->
                <li key={'new_' + index} className='ui-set-list-item'>
                  <label>
                    <input type='hidden'
                      name={('new_collections[new_' + index + '][checked]')}
                      value='false'></input>
                    <input type='hidden'
                      name={('new_collections[new_' + index + '][name]')}
                      value={row}></input>
                    <ControlledCheckbox className='ui-set-list-input'
                      name={('new_collections[new_' + index + '][checked]')}
                      value='true' checked={true} />
                    <span className='title'>{row}</span>
                    <span className='owner'>{get.current_user.label}</span>
                    <span className='created-at'>{t('resource_select_collection_new')}</span>
                  </label>
                </li>
          }

          {

            if @state.searching
              <Preloader style={{marginTop: '20px'}}/>
            else if hasResultEntries
              f.map get.collection_rows, (row) ->
                collection = row.collection
                checked = row.contains_media_entry
                <li key={collection.uuid} className='ui-set-list-item'>
                  <label>
                    <input type='hidden'
                      name={('selected_collections[' + collection.uuid + '][]')}
                      value='false'></input>
                    <ControlledCheckbox className='ui-set-list-input'
                      name={('selected_collections[' + collection.uuid + '][]')}
                      value='true' checked={checked} />
                    <span className='title'>{collection.title}</span>
                    <span className='owner'>{collection.authors_pretty}</span>
                    <span className='created-at'>{collection.created_at_pretty}</span>
                  </label>
                </li>

          }


        </ol>
      )


    if not hasResultEntries and f.presence(get.search_term) and not @state.searching
      _content.push(
        <h3 key='content3' className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
      )

    if not hasResultEntries and not f.presence(get.search_term) and not @state.searching
      _content.push(
        <h3 key='content4' className="by-center title-m">{t('resource_select_collection_non_assigned')}</h3>
      )


    <SelectCollectionDialog
      onCancel={@props.onClose}
      cancelUrl={get.resource_url}
      title={t('resource_select_collection_title')}
      toolbar={_search}
      action={get.add_remove_collection_url}
      authToken={authToken}
      content={_content}
      method='patch'
      showSave={true}
      showAddToClipboard={true} />


ControlledCheckbox = React.createClass
  displayName: 'ControlledCheckbox'

  getInitialState: () -> {
    checked: false
  }

  componentWillMount: () ->
    @setState(checked: @props.checked)

  _onChange: (event) ->
    @setState(checked: event.target.checked)

  render: ({children} = @props) ->
    <input className={@props.className} type='checkbox'
      name={@props.name}
      value={@props.value} checked={@state.checked}
      onChange={@_onChange}></input>
