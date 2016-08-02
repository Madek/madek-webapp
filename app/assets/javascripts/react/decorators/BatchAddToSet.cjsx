React = require('react')
f = require('active-lodash')
t = require('../../lib/string-translation.js')('de')
PageContent = require('../views/PageContent.cjsx')
PageContentHeader = require('../views/PageContentHeader.cjsx')
TabContent = require('../views/TabContent.cjsx')
Tabs = require('../views/Tabs.cjsx')
Tab = require('../views/Tab.cjsx')
ResourceThumbnail = require('./ResourceThumbnail.cjsx')
Thumbnail = require('../ui-components/Thumbnail.cjsx')
batchDiff = require('../../lib/batch-diff.coffee')
BatchHintBox = require('./BatchHintBox.cjsx')
ResourcesBatchBox = require('./ResourcesBatchBox.cjsx')
SelectCollectionDialog = require('../views/Collection/SelectCollectionDialog.cjsx')

Button = require('../ui-components/Button.cjsx')
Icon = require('../ui-components/Icon.cjsx')
RailsForm = require('../lib/forms/rails-form.cjsx')
InputFieldText = require('../lib/forms/input-field-text.cjsx')
formXhr = require('../../lib/form-xhr.coffee')
setUrlParams = require('../../lib/set-params-for-url.coffee')
Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass
  displayName: 'BatchAddToSet'

  getInitialState: () -> {
    mounted: false,
    searchTerm: '',
    results: [],
    searching: false
  }

  componentWillMount: () ->
    @setState(get: @props.get, searchTerm: @props.get.search_term)

  componentDidMount: () ->
    @setState(mounted: true)


  _onChange: (event) ->
    @setState({searchTerm: event.target.value})

    # if @props.onClose
    @setState({searching: true})

    # TODO: Kill all before!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if @lastRequest
      @lastRequest.abort()

    url = @_requestUrl()

    @lastRequest = formXhr(
      {
        method: 'GET'
        url: url
        form: @refs.form
      },
      (result, json) =>
        if result == 'success'
          @setState({get: json, searching: false}) if @isMounted()
    )

  _requestUrl: () ->
    setUrlParams(
      @props.get.batch_select_add_to_set_url,
      {
        resource_id: @props.get.resource_ids
        search_term: @state.searchTerm
        return_to: @state.get.return_to
      }
    )


  render: ({authToken} = @props) ->

    get = @state.get

    buttonMargins = {
      marginTop: '5px'
      marginRight: '5px'
    }

    _search =
      <div className='ui-search'>
        <RailsForm ref='form' name='search_collections' action={@_requestUrl()}
            method='get' authToken={authToken} className='dummy'>

          <input type='hidden' name='return_to' value={@state.get.return_to} />
          <input type='text' autoCorrect='off' autoComplete='off' autofocus='autofocus'
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
          }
        </RailsForm>
      </div>

    _content =
      if @state.searching
        <Preloader />
      else if get.search_results.length > 0
        <div className='ui-resources-table'>
          <div className='ui-resources-table'>
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
            <table className='block'>
              <tbody>
                {
                  f.map get.search_results, (collection, index) ->
                    <tr key={'result_' + index}>
                      <td data-name='title' title=''>
                        <img className='ui-thumbnail micro' src={collection.image_url}></img>
                      </td>
                      <td data-name='title' title=''>
                        <span className='ui-resources-table-cell-content'>{collection.title}</span>
                      </td>
                      <td data-name='title' title=''>
                        <Button style={{float: 'right'}} className="primary-button"
                          type='submit' value={collection.uuid} name={'parent_collection_id'}>
                          Zu diesem hinzufügen
                        </Button>
                      </td>
                    </tr>
                }
              </tbody>
            </table>
          </div>
        </div>
      else if f.presence(get.search_term)
        <h3 key='content3' className="by-center title-m">{t('resource_select_collection_non_found')}</h3>
      else
        <h3 key='content3' className="by-center title-m">{t('batch_add_to_collection_hint')}</h3>




    <SelectCollectionDialog
      onCancel={@props.onClose}
      cancelUrl={@state.get.return_to}
      title={t('batch_add_to_collection_pre') + @props.get.batch_count + t('batch_add_to_collection_post')}
      toolbar={_search}
      action={get.batch_add_to_set_url}
      authToken={authToken}
      content={_content}
      method='put'
      showSave={false} />
