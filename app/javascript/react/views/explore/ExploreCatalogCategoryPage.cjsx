React = require('react')
ReactDOM = require('react-dom')
t = require('../../../lib/i18n-translate.js')
f = require('lodash')
classnames = require('classnames')
UI = require('../../ui-components/index.js')
Preloader = require('../../ui-components/Preloader.cjsx')
loadXhr = require('../../../lib/load-xhr.js')
libUrl = require('url')
setUrlParams = require('../../../lib/set-params-for-url.js')


module.exports = React.createClass
  displayName: 'ExploreCatalogCategoryPage'

  getInitialState: () ->
    {
      metaKeyValuePages: [
        @_initialMetaKeyValuePage()
      ],
      loading: false
    }

  _initialMetaKeyValuePage: () ->
    f.cloneDeep(@props.get.meta_key_values)

  _lastPage: () ->
    f.last(@state.metaKeyValuePages)

  _tryLoadNext: () ->

    return if @state.loading

    return if !@_isBottom()

    return if !@_lastPage().has_more

    @setState(
      loading: true,
      () =>
        @_ajaxRequest()
    )


  _ajaxRequest: () ->

    lastPage = @_lastPage()

    url = setUrlParams(
      libUrl.parse(@props.for_url).pathname,
      {
        page_size: 3,
        start_index: lastPage.start_index + lastPage.page_size

      }
    )

    @xhrRef = loadXhr(
      {
        method: 'GET'
        url: url
      },
      (result, data) =>

        if result == 'success'
          @setState(metaKeyValuePages: f.concat(@state.metaKeyValuePages, data.meta_key_values))

        @setState(
          loading: false,
          () =>
            @_tryLoadNext()
        )
    )





  _getDocHeight: () ->
    D = document
    Math.max(
        D.body.scrollHeight, D.documentElement.scrollHeight,
        D.body.offsetHeight, D.documentElement.offsetHeight,
        D.body.clientHeight, D.documentElement.clientHeight
    )

  _scrollTop: () ->
    Math.max(
      document.body.scrollTop, document.documentElement.scrollTop
    )

  _isBottom: () ->
    # console.log(@_scrollTop() + ' + ' + window.innerHeight + ' == ' + @_getDocHeight())
    @_scrollTop() + window.innerHeight > @_getDocHeight() * 0.3 || window.innerHeight > @_getDocHeight() * 0.3# || @_getDocHeight() < 3000


  componentDidMount: () ->
    @_tryLoadNext()
    window.addEventListener('scroll', @_onScroll);

  componentWillUnmount: () ->
    # Assumption:
    # If your XHR is pending, and you go to the next page and use the browser back button, then
    # you most likely do not enter the XHR callback, which in this component means,
    # that the next page is not loaded. Thats why we explicitly cancel it.
    if @xhrRef
      @xhrRef.cancel()
    window.removeEventListener('scroll', @_onScroll);


  _onScroll: () ->
    @_tryLoadNext()

  render: ({get, authToken} = @props) ->
    <div>
      <div className="app-body-ui-container pts context-home">


        <h1 className='title-xl mtl mbm'>
          {get.catalog_title + ' / ' + get.title}
        </h1>

        <div className='ui-resources-holder pal'>

          {
            f.compact(f.map(
              f.flatten(f.map(
                @state.metaKeyValuePages,
                (page) ->
                  page.values

              )),

              (keyword) =>

                if f.isEmpty(keyword.media_entries)
                    return null

                <div key={keyword.uuid}>
                  <div className='ui-resources-header'>
                    <h2 className='title-l ui-resource-title' style={{marginBottom: '15px'}}>
                      {keyword.label}
                      <a className='strong' href={keyword.url}>
                        {
                          t('explore_show_more')
                        }
                      </a>
                    </h2>
                  </div>
                  <MediaResourcesLine keyword={keyword} />
                </div>

            ))
          }

          {
            if @_lastPage().has_more
              <Preloader />

          }
        </div>
      </div>
    </div>



MediaResourcesLine = ({keyword, asyncData} = props) ->

  resources = f.map(keyword.media_entries, 'sparse_props')

  <div className='ui-container rounded-right pbm' key={keyword.uuid}>
    <div className='ui-container rounded-right'>
      <div className='ui-featured-entries small active'>
        <ul className='ui-featured-entries-list'>
          {
            f.map(resources, ({uuid, url, browse_url, image_url, media_type}) ->
              <li key={keyword.uuid + '_' + uuid} className='ui-featured-entries-item'>
                <a
                  className={classnames('ui-featured-entry', {"is-#{media_type}": !!media_type})}
                  href={url}
                >
                  <img src={image_url} />
                </a>
                <ul className='ui-featured-entry-actions'>
                  <li className='ui-featured-entry-action'>
                    <a
                      className='block'
                      href={browse_url}
                      title={t('browse_entries_browse_link_title')}
                    >
                      <UI.Icon i='eye' />
                    </a>
                  </li>
                </ul>
              </li>
            )
          }
        </ul>
      </div>
    </div>
    <hr className='separator' />
  </div>
