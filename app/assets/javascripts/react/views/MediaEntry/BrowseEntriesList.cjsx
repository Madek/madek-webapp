React = require('react')
f = require('active-lodash')
classList = require('classnames')

t = require('../../../lib/string-translation')('de')
UI = require('../../ui-components/index.coffee')
MadekPropTypes = require('../../lib/madek-prop-types.coffee')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
ResourceThumbnail = require('../../decorators//ResourceThumbnail.cjsx')

MAIN_TITLE = 'Verwandte Medieneinträge'

VIEW_EXPLANATION = <p className='mvm'>
  <b className='title-s'>Beta-Feature!</b><br/>
  Diese Ansicht dient zum Evaluieren der Ergebnisse einer experimentellen
  "Stöbern"-Query.<br/>
  Sie ist KEIN Design-Vorschlag!<br/>
  Der obere Teil zeigt verwandte Einträge nach gemeinsamen Schlagworten sortiert;
  und soll die Frage beantworten: "Sind dies im allgemeinen interessante Vorschläge oder brauchen wir einen ganz anderen Ansatz?".<br/>
  Der untere Teil zeigt die selben Einträge, allerdings nach exakt gemeinsamen Schlagworten
  GECLUSTERT – sinnvoll zum bewerten der Vorschläge ("Warum genau ist dies verwandt?")
</p>


module.exports = React.createClass
  displayName: 'Views.MediaEntry.BrowseEntriesList'

  render: ({browse, isLoading, titleLink, authToken} = @props)->
    titleHeader = <h3 className='title-l'>
      {MAIN_TITLE}{' '}
      {if titleLink
        <a href={titleLink} style={{textDecoration: 'none'}}>
          <UI.Icon i='link' />
        </a>}
    </h3>

    # fallback view
    if isLoading or !browse then return <div>
      {titleHeader}
      {(!isLoading && !browse) ? 'Ladefehler!' : <UI.Preloader mods='mal'/>}
      <hr className='separator light'/>
      {VIEW_EXPLANATION}
    </div>

    # main view
    ranked_entries = f.map(browse.entry_ids_by_rank, (id) -> browse.entries_by_id[id])
    entries_by_shared_keywords = f.map(browse.entry_ids_by_shared_keywords, ({keyword_ids, entry_ids}) ->
        {
          keywords: keyword_ids.map((id) -> browse.keywords_by_id[id])
          entries: entry_ids.map((id) -> browse.entries_by_id[id])
        }
      )

    <div>
      {titleHeader}

      {if f.isEmpty(ranked_entries)
        <div className='pal by-center'>{t('no_content_fallback')}</div>
      else
        <div>
          <dl className="media-data">
            <dt className='media-data-title title-xs-alt'>Alle Schlagworte des Eintrags, für die es weitere Einträge gibt und Liste der 100 "ähnlichsten" Einträge</dt>
            <dd className='media-data-content'>
              <ul className='ui-tag-cloud ellipsed compact pts'>
                {f.map browse.common_keywords, (id) ->
                  kw = browse.keywords_by_id[id]
                  <KeywordItem {...kw} key={kw.uuid}/>
                }
              </ul>
            </dd>
          </dl>

          <div className='pam'>
            <MediaResourcesGrid resources={ranked_entries} authToken={authToken}/>
          </div>

          <hr className='separator mvm'/>

          <h3 className='title-l'>Verwandte Medieneinträge (Cluster)</h3>

          {f.map(entries_by_shared_keywords, ({keywords, entries}) ->
            <div key={f.map(keywords, 'uuid').join('.')}>
              <dl className="media-data">
                <dt className='media-data-title title-xs-alt'>gemeinsame Schlagworte</dt>
                <dd className='media-data-content'>
                  <ul className='ui-tag-cloud ellipsed compact pts'>
                    {f.map f.sortBy(keywords, 'label'), (kw) -> <KeywordItem {...kw} key={kw.uuid}/> }
                  </ul>
                </dd>
              </dl>

              <div className='pam'>
                <MediaResourcesGrid resources={entries} authToken={authToken}/>
              </div>

            </div>
          )}
        </div>
      }

      <hr className='separator'/>

      {VIEW_EXPLANATION}
    </div>

KeywordItem = ({uuid, label, url}) ->
  <li className='ui-tag-cloud-item'>
    <a className='ui-tag-button' title={label} href={url}>
      {label}
    </a>
  </li>

# like MediaResourcesBox, but in as a simple grid with fixes order
MediaResourcesGrid = ({resources, authToken} = props)->
    isClient = !!(window && window.document && window.document.body)

    <div className='ui-container ui-minibox'>
      <ul className='ui-resources grid active'>
        <li className='ui-resources-page'>
          <ul className='ui-resources-page-items'>
            {
              f.map resources, (item)=>
                key = item.uuid or item.cid

                <ResourceThumbnail elm='li'
                  key={key}
                  get={item}
                  isClient={isClient}
                  fetchRelations={true}
                  authToken={authToken}
                />
            }

          </ul>
        </li>
      </ul>
    </div>


## v2 "line of thumbs" style:
#
# <div key='div' className='ui-container midtone rounded-right ptl phl pbm'>
#   <div className='ui-resources-header mbm'>
#     <h2 className='title-m ui-resources-title'>
#       <strong className='ui-resource-title-core'>
#         ZHdK-Projekttyp:
#       </strong>
#       Dokumentation
#       <span className='ui-counter'>
#         4053
#       </span>
#       <a
#         className='strong'
#         href='/media_resources?meta_data%5Bproject+type%5D%5Bids%5D%5B%5D=09ef2968-b8bd-460d-864b-0ee3ae363380'
#       >
#         Alle anzeigen
#       </a>
#     </h2>
#   </div>
#   <div className='ui-featured-entries small active'>
#     <ul
#       className='ui-featured-entries-list'
#       data-meta-key='project type'
#       data-meta-term='09ef2968-b8bd-460d-864b-0ee3ae363380'
#     >
#       <li className='ui-featured-entries-item'>
#         <a
#           className='ui-featured-entry'
#           href='/media_resources/9e1c2ec2-811a-4c6a-a627-683b64ec4819'
#         >
#           <img
#             src='/media_resources/9e1c2ec2-811a-4c6a-a627-683b64ec4819/image?size=medium'
#           />
#           {' '}
#         </a>
#         <ul className='ui-featured-entry-actions'>
#           <li className='ui-featured-entry-action'>
#             <a
#               className='block'
#               href='/media_resources/9e1c2ec2-811a-4c6a-a627-683b64ec4819/browse'
#               title='In diese Richtung weiterstöbern'
#             >
#               <i className='icon-eye' />
#             </a>
#             {' '}
#           </li>
#         </ul>
#       </li>
#     </ul>
#   </div>
# </div>,
# <hr key='hr', className='separator' />
