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
SelectCollectionDialog = require('./SelectCollectionDialog.cjsx')

module.exports = React.createClass
  displayName: 'SelectCollection'

  getInitialState: () -> {
    mounted: false
    errors: null
    searching: false
    searchTerm: ''
    newSets: []
    get: null
  }

  lastRequest: null

  componentWillMount: () ->
    # @setState({searchTerm: @props.boot.search_term})
    @setState(searchTerm: @props.get.search_term, get: @props.get)


  componentDidMount: () ->
    @setState(mounted: true)

  _onClickNew: (event) ->
    event.preventDefault()

    if @state.searchTerm
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
        url: @props.get.select_collection_url
        form: @refs.form
      },
      (result, json) =>
        if result == 'success'
          @setState({get: json.header.collection_selection, searching: false})
    )



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

    showNew = @state.newSets.length > 0
    showEntries = get.collection_rows.length isnt 0


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

    if @state.searching and not (showNew or showEntries)
      _content.push(
        <Preloader key='content1' />
      )


    if showNew or showEntries
      _content.push(
        <ol key='content2' className='ui-set-list pbs'>

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
                    <span className='owner'>{collection.authors_pretty}</span>
                    <span className='created-at'>{collection.created_at_pretty}</span>
                  </label>
                </li>

          }


        </ol>
      )


    if get.collection_rows.length is 0 and f.presence(get.search_term) and not @state.searching
      _content.push(
        <h3 key='content3' className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
      )

    if get.collection_rows.length is 0 and not f.presence(get.search_term) and not @state.searching
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
      showSave={true} />
