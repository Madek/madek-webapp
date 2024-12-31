React = require('react')
f = require('active-lodash')
t = require('../../lib/i18n-translate.js')
PageContent = require('../views/PageContent.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')
batchDiff = require('../../lib/batch-diff.coffee')
BatchHintBox = require('./BatchHintBox.cjsx')
SelectCollectionDialog = require('../views/Collection/SelectCollectionDialog.cjsx')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
RailsForm = require('../lib/forms/rails-form.cjsx')
formXhr = require('../../lib/form-xhr.coffee')
setUrlParams = require('../../lib/set-params-for-url.coffee')
Preloader = require('../ui-components/Preloader.cjsx')

qs = require('qs')
getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee')
xhr = require('xhr')

module.exports = React.createClass
  displayName: 'BatchAddToSet'

  getInitialState: () -> {
    mounted: false
    searchTerm: ''
    searching: false
    newSets: []
    results: []
  }

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

        data = {
          resource_id: @props.get.resource_ids
          search_term: @state.searchTerm
          return_to: @state.get.return_to
        }

        body = qs.stringify(
          data,
          {
            arrayFormat: 'brackets' # NOTE: Do it like rails.
          }
        )

        @lastRequest = xhr(
          {
            url: @props.get.batch_select_add_to_set_url,
            method: 'POST',
            body: body,
            headers: {
              'Accept': 'application/json',
              'Content-type': 'application/x-www-form-urlencoded',
              'X-CSRF-Token': getRailsCSRFToken()
            }
          },
          (err, res, json) =>
            if err || res.statusCode != 200
              return
            else
              @setState({get: JSON.parse(json), searching: false}) if @isMounted()
        )
      ,
      500
    )

  _onClickNew: (event) ->
    event.preventDefault()

    if @state.searchTerm
      trimmed = @state.searchTerm.trim()
      if trimmed.length > 0
        @state.newSets.push(trimmed)
        @setState({newSets: @state.newSets})

    return false



  render: ({authToken} = @props) ->

    get = @state.get

    buttonMargins = {
      marginTop: '5px'
      marginRight: '5px'
    }

    hasNew = @state.newSets.length > 0
    hasResultEntries = get.search_results.collections.length > 0 # get.collection_rows.length isnt 0


    _search =
      <div className='ui-search'>
        <RailsForm ref='form' name='search_collections' action={@props.get.batch_select_add_to_set_url}
            method='post' authToken={authToken} className='dummy'>

          <input type='hidden' name='return_to' value={@state.get.return_to} />
          <input type='text' autoCorrect='off' autoComplete='off' autoFocus='autofocus'
            className='ui-search-input block'
            placeholder={t('resource_select_collection_search_placeholder')}
            name='search_term' value={@state.searchTerm}
            onChange={@_onChange}/>
          {
            f.map @props.get.resource_ids, (resource_id) ->
              [
                <input key={'resource_id_' + resource_id.uuid} type='hidden'
                  name='resource_id[][uuid]' value={resource_id.uuid} />
                ,
                <input key={'resource_id_' + resource_id.type} type='hidden'
                  name='resource_id[][type]' value={resource_id.type} />
              ]
          }
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
          <input type='hidden' name='return_to' value={@state.get.return_to} />
          {
            f.map @props.get.resource_ids, (resource_id) ->
              [
                <input key={'resource_id_' + resource_id.uuid} type='hidden'
                  name='resource_id[][uuid]' value={resource_id.uuid} />
                ,
                <input key={'resource_id_' + resource_id.type} type='hidden'
                  name='resource_id[][type]' value={resource_id.type} />
              ]
          }


          {
            if hasNew
              f.map @state.newSets, (row, index) ->
                <li style={{paddingLeft: '60px', paddingRight: '200px'}}
                  key={'new_' + index} className='ui-set-list-item'>
                  <img style={{margin: '0px', position: 'absolute', left: '10px', top: '10px'}}
                    className='ui-thumbnail micro' src={null}></img>
                  <span className='title'>{row}</span>
                  <span className='owner'>{'New'}</span>
                  <Button style={{position: 'absolute', right: '0px', top: '10px'}} className="primary-button"
                    type='submit' value={row} name={'parent_collection_id[new]'}>
                    Neues Set erstellen und Einträge hinzufügen
                  </Button>
                </li>
          }

          {
            if @state.searching
              <Preloader style={{marginTop: '20px'}}/>
            else if hasResultEntries
              f.map get.search_results.collections, (collection, index) ->
                <li style={{paddingLeft: '60px', paddingRight: '200px'}}
                  key={collection.uuid} className='ui-set-list-item'>
                  <img style={{margin: '0px', position: 'absolute', left: '10px', top: '10px'}}
                    className='ui-thumbnail micro' src={collection.image_url}></img>
                  <span className='title'>{collection.title}</span>
                  <span className='owner'>{collection.responsible.name}</span>
                  <span className='created-at'>{collection.created_at_pretty}</span>
                  <Button style={{position: 'absolute', right: '0px', top: '10px'}} className="primary-button"
                    type='submit' value={collection.uuid} name={'parent_collection_id[existing]'}>
                    Zu diesem hinzufügen
                  </Button>
                </li>
          }
        </ol>
      )


    if !@state.searching && hasResultEntries && get.search_results.has_more
      _content.push(
        <h3 key='content3' className="by-center title-m">{t('resource_select_collection_has_more')}</h3>
      )

    if not hasResultEntries and f.presence(get.search_term) and not @state.searching
      _content.push(
        <h3 key='content3' className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
      )

    if not hasResultEntries and not f.presence(get.search_term) and not @state.searching
      _content.push(
        <h3 key='content4' className="by-center title-m">{t('batch_add_to_collection_hint')}</h3>
      )

    <SelectCollectionDialog
      onCancel={@props.onClose}
      cancelUrl={@state.get.return_to}
      title={t('batch_add_to_collection_pre') + @props.get.batch_count + t('batch_add_to_collection_post')}
      toolbar={_search}
      action={get.batch_add_to_set_url}
      authToken={authToken}
      content={_content}
      method='put'
      showSave={false}
      showAddToClipboard={false} />
