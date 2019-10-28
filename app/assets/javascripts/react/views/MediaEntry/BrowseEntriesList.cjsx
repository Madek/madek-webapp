React = require('react')
f = require('active-lodash')
classList = require('classnames')

t = require('../../../lib/i18n-translate.js')
qs = require('qs')
url = require('url')
parseUrl = require('url').parse
setUrlParams = require('../../../lib/set-params-for-url.coffee')
UI = require('../../ui-components/index.coffee')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
ResourceThumbnail = require('../../decorators//ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'Views.MediaEntry.BrowseEntriesList'

  render: ({browse, isLoading, header, authToken} = @props)->
    loadingError = t('browse_entries_loading_error')
    # fallback view
    if isLoading or !browse then return <div>
      {header}
      {(!isLoading && !browse) ? loadingError : <UI.Preloader mods='mal'/>}
    </div>

    # main view
    keyword_clusters = f.map(browse.entry_ids_by_shared_keywords, ({keyword_ids, entry_ids}) ->
      keywords = keyword_ids.map((id) ->
        kw = browse.keywords_by_id[id]
        mk = browse.meta_keys_by_id[kw.meta_key_id]
        voc = browse.vocabularies_by_id[mk.vocabulary_id]
        f.assign({}, kw, metaKey: f.assign({}, mk, vocabulary: voc))
      )
      keywordsGrouped = f.values(f.groupBy(keywords, 'meta_key_id'))
      keywordsSorted = f.sortBy(
        f.sortBy(keywordsGrouped, '0.metaKey.position'),
        '0.metaKey.vocabulary.position')

      {
        entries: entry_ids.map((id) -> browse.entries_by_id[id]),
        keywordsByMetaKey: keywordsSorted
      }
    )

    <div data-ui-entry-browse-list>
      {header}
      {if f.isEmpty(keyword_clusters)
        <div className='by-center'>{t('no_content_fallback')}</div>
      else
        <div>
          {f.map(keyword_clusters, ({keywordsByMetaKey, entries}) ->
            <MediaResourcesLine
              resources={entries}
              authToken={authToken}
              key={f.get(entries, '0.uuid')}
            >
              {f.map(keywordsByMetaKey, (keywords, index, list) ->
                metaKey = f.get(keywords, '0.metaKey')
                isLast = (index == (list.length - 1))

                <span key={f.map(keywords, 'uuid').join('')}>
                  <span className='title-xs'>{metaKey.label}{' '}</span>
                  <ul className='ui-tag-cloud-small' style={{display: 'inline'}}>
                    {f.map keywords, (kw) ->
                      <KeywordItem {...kw} key={kw.uuid}/>
                    }
                  </ul>
                </span>
              )}

              <a
                className='strong'
                href={entriesFilterPath(browse.filter_search_path, f.flatten(keywordsByMetaKey))}
              >
                {t('browse_entries_filter_link')}
              </a>
            </MediaResourcesLine>
          )}

        </div>
      }
    </div>

entriesFilterPath = (path, keywords) ->
  setUrlParams(path, {list: {
    show_filter: true,
    filter: JSON.stringify({
      meta_data: f.map(keywords, (kw) -> { value: kw.uuid, key: kw.meta_key_id })
    })
  }})


KeywordItem = ({uuid, label, url}) ->
  <li className='ui-tag-cloud-item'>
    <a className='ui-tag-button' title={label} href={url}>
      {label}
    </a>
  </li>


MediaResourcesLine = ({resources, children, authToken} = props)->
  <div className='ui-container rounded-right pbm'>
    <div className='ui-container rounded-right'>
      {children && <div className='mbm'>{children}</div>}
      <div className='ui-featured-entries small active'>
        <ul
          className='ui-featured-entries-list'
        >
          {f.map(resources, ({uuid, url, image_url, media_type}) ->
            <li  key={uuid} className='ui-featured-entries-item'>
              <a
                className={classList('ui-featured-entry', {"is-#{media_type}": !!media_type})}
                href={url}
              >
                <img src={image_url} />
              </a>
              <ul className='ui-featured-entry-actions'>
                <li className='ui-featured-entry-action'>
                  <a
                    className='block'
                    href={makeBrowseUrl(url)}
                    title={t('browse_entries_browse_link_title')}
                  >
                    <UI.Icon i='eye' />
                  </a>
                </li>
              </ul>
            </li>
          )}
        </ul>
      </div>
    </div>
    <hr className='separator' />
  </div>


makeBrowseUrl = (url) ->
  parsedUrl = parseUrl(url)
  params = qs.parse(parsedUrl.query)
  parsedUrl.pathname.replace(/\/*$/, '') + '/browse?' + qs.stringify(params)
