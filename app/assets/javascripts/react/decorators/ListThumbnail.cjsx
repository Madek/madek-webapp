React = require('react')
async = require('async')
f = require('active-lodash')
c = require('classnames')
t = require('../../lib/string-translation')('de')
Picture = require('../ui-components/Picture.cjsx')
Button = require('../ui-components/Button.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
FavoriteButton = require('./thumbnail/FavoriteButton.cjsx')
DeleteModal = require('./thumbnail/DeleteModal.cjsx')
StatusIcon = require('./thumbnail/StatusIcon.cjsx')
ListThumbnail = require('./ListThumbnail.cjsx')
MetaDataList = require('./MetaDataList.cjsx')
MetaDatumValues = require('./MetaDatumValues.cjsx')
LoadXhr = require('../../lib/load-xhr.coffee')
Preloader = require('../ui-components/Preloader.cjsx')

module.exports = React.createClass
  displayName: 'ListThumbnail'

  _listRenderer: (listingData, fallbackMsg, tagMods) ->

    fallbackMsg = null

    <table className="borderless block">
      <tbody>
      {
        if fallbackMsg
          <tr><td className="ui-resource-meta-label">{fallbackMsg}</td></tr>
        else
          f.map listingData, (item) ->
            <tr key={item.key}>
              <td className="ui-resource-meta-label">{item.key}</td>
              <td className="ui-resource-meta-content">
                <MetaDatumValues metaDatum={item.value} tagMods={tagMods}/>
              </td>
            </tr>
      }
      </tbody>
    </table>


  render: ({resourceType, imageUrl, mediaType, title, subtitle, mediaUrl, metaData} = @props) ->

    listsWithClasses = []
    if metaData
      if metaData.contexts_for_list_details.length > 0
        listsWithClasses.push({
          className: 'ui-resource-meta'
          list: metaData.contexts_for_list_details[0]
        })
      if metaData.contexts_for_list_details.length > 1
        listsWithClasses.push({
          className: 'ui-resource-description'
          list: metaData.contexts_for_list_details[1]
        })
      if metaData.contexts_for_list_details.length > 2
        listsWithClasses.push({
          className: 'ui-resource-extension'
          list: metaData.contexts_for_list_details[2]
        })

    innerImage = if imageUrl
      <Picture mods='ui-thumbnail-image' src={imageUrl} alt={title} />
    else
      <ResourceIcon mediaType={mediaType} thumbnail={true} tiles={false}
        type={resourceType} overrideClasses='ui-thumbnail-image' />

    thumbnailClass = f.kebabCase(resourceType.replace(/Collection/, 'MediaSet'))

    <li className="ui-resource" style={@props.style}>
      <div className="ui-resource-head">
        <ResourceActions />
        <h3 className="ui-resource-title">{title}</h3>
      </div>
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <div className={c('ui-thumbnail', thumbnailClass)}>
            <LevelUp />
            <div className="ui-thumbnail-privacy">
              <i className="icon-privacy-group"></i>
            </div>
            <Image innerImage={innerImage} mediaUrl={mediaUrl} />
            <Titles />
            <ThumbnailActions />
            <Dropdown />
            <LevelDown />
          </div>
        </div>
        {
          if true
            if @props.loadingMetadata
              <Preloader />
            else
              f.map(listsWithClasses, (item, index) =>
                <div className={item.className} key={'list_' + index}>
                  <MetaDataList showTitle={false} mods='ui-resource-meta' listMods='block' type='table'
                    list={item.list} renderer={@_listRenderer}/>
                </div>
              )
          else
            <Meta />
            <Description />
            <Extension />
        }

      </div>
    </li>


Image = React.createClass
  displayName: 'Image'
  render: ({old, innerImage, mediaUrl} = @props) ->
    if old
      <a className="ui-thumbnail-image-wrapper">
        <div className="ui-thumbnail-image-holder">
          <div className="ui-thumbnail-table-image-holder">
            <div className="ui-thumbnail-cell-image-holder">
              <div className="ui-thumbnail-inner-image-holder">
                <img alt="Media-entry-6" className="ui-thumbnail-image"
                  src="/dev-assets/styleguide/media-entry-6.jpeg" />
              </div>
            </div>
          </div>
        </div>
      </a>
    else
      <a className="ui-thumbnail-image-wrapper" href={mediaUrl}>
        <div className="ui-thumbnail-image-holder">
          <div className="ui-thumbnail-table-image-holder">
            <div className="ui-thumbnail-cell-image-holder">
              <div className="ui-thumbnail-inner-image-holder">
                {innerImage}
              </div>
            </div>
          </div>
        </div>
      </a>


Titles = React.createClass
  displayName: 'Titles'
  render: () ->
    <div className="ui-thumbnail-meta">
      <h3 className="ui-thumbnail-meta-title">Name that can easily go onto 2 lines</h3>
      <h4 className="ui-thumbnail-meta-subtitle">Author that can easily go onto 2 lines as well</h4>
    </div>


ThumbnailActions = React.createClass
  displayName: 'ThumbnailActions'
  render: () ->
    <div className="ui-thumbnail-actions">
      <ul className="left by-left">
        <li className="ui-thumbnail-action">
          <a className="ui-thumbnail-action-checkbox active" data-clipboard-toggle=""
            title="Zur Zwischenablage hinzufügen/entfernen">
            <i className="icon-checkbox"></i>
          </a>
        </li>
        <li className="ui-thumbnail-action">
          <a className="active ui-thumbnail-action-favorite" data-favor-toggle=""
            title="Zur Favoriten hinzufügen/entfernen">
            <i className="icon-star-empty"></i>
          </a>
        </li>
      </ul>
      <ul className="right by-right">
        <li className="ui-thumbnail-action">
          <a className="ui-thumbnail-action-browse" href="#" title="Stöbern">
            <i className="icon-eye"></i>
          </a>
        </li>
        <li className="ui-thumbnail-action">
          <a className="ui-thumbnail-action-edit" href="#" title="Metadaten editieren">
            <i className="icon-pen"></i>
          </a>
        </li>
        <li className="ui-thumbnail-action">
          <a className="ui-thumbnail-action-delete" data-delete-action="" title="Löschen">
            <i className="icon-trash"></i>
          </a>
        </li>
      </ul>
    </div>

ResourceActions = React.createClass
  displayName: 'ResourceActions'
  render: () ->
    <ul className="ui-resource-actions">
      <li className="ui-resource-action">
        <a className="ui-thumbnail-action-checkbox" data-clipboard-toggle="" title="Zur Zwischenablage hinzufügen/entfernen">
          <i className="icon-checkbox"></i>
        </a>
      </li>
      <li className="ui-resource-action">
        <a className="ui-thumbnail-action-favorite" data-favor-toggle="" title="Zur Favoriten hinzufügen/entfernen">
          <i className="icon-star-empty"></i>
        </a>
      </li>
    </ul>

LevelUp = React.createClass
  displayName: 'LevelUp'
  render: () ->
    <div className="ui-thumbnail-level-up-items">
      <h3 className="ui-thumbnail-level-notes">Set enthalt</h3>
      <ul className="ui-thumbnail-level-items">
        <li className="ui-thumbnail-level-item odd">
          <a className="ui-level-image-wrapper" href="#" title="Set name">
            <div className="ui-thumbnail-level-image-holder">
              <img alt="Media-entry-6" className="ui-thumbnail-level-image"
                src="/dev-assets/styleguide/media-entry-6.jpeg" />
            </div>
          </a>
        </li>
        <li className="ui-thumbnail-level-item even">
          <a className="ui-level-image-wrapper" href="#" title="Set name">
            <div className="ui-thumbnail-level-image-holder">
              <img alt="Media-entry-6" className="ui-thumbnail-level-image"
                src="/dev-assets/styleguide/media-entry-6.jpeg" />
            </div>
          </a>
        </li>
      </ul>
      <span className="ui-thumbnail-level-notes">5 Inhalte</span>
    </div>

Dropdown = React.createClass
  displayName: 'Dropdown'
  render: () ->
    <div className="ui-thumbnail-dropdown">
      <div className="dropdown ui-dropdown">
        <a className="dropdown-toggle ui-drop-toggle button block" data-toggle="dropdown" href="#">Aktionen</a>
        <ul aria-labelledby="dLabel" className="dropdown-menu ui-drop-menu" role="menu">
          <li className="ui-drop-item">
            <a href="#">Item 1</a>
          </li>
          <li className="ui-drop-item">
            <a href="#">Item 2</a>
          </li>
          <li className="separator"></li>
          <li className="ui-drop-item">
            <a href="#">Item 3</a>
          </li>
        </ul>
      </div>
    </div>

LevelDown = React.createClass
  displayName: 'LevelDown'
  render: () ->
    <div className="ui-thumbnail-level-down-items">
      <h3 className="ui-thumbnail-level-notes">Set enthalt</h3>
      <ul className="ui-thumbnail-level-items">
        <li className="ui-thumbnail-level-item odd">
          <a className="ui-level-image-wrapper" href="#" title="Set name">
            <div className="ui-thumbnail-level-image-holder">
              <img alt="Media-entry-6" className="ui-thumbnail-level-image" src="/dev-assets/styleguide/media-entry-6.jpeg" />
            </div>
          </a>
        </li>
        <li className="ui-thumbnail-level-item even">
          <a className="ui-level-image-wrapper" href="#" title="Set name">
            <div className="ui-thumbnail-level-image-holder">
              <img alt="Media-entry-6" className="ui-thumbnail-level-image" src="/dev-assets/styleguide/media-entry-6.jpeg" />
            </div>
          </a>
        </li>
      </ul>
      <span className="ui-thumbnail-level-notes">5 Inhalte</span>
    </div>

Meta = React.createClass
  displayName: 'Meta'
  render: () ->
    <div className="ui-resource-meta">
      <table className="borderless block">
        <tbody>
          <tr>
            <td className="ui-resource-meta-label">Autor/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Datierung</td>
            <td className="ui-resource-meta-content">1470/1500</td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Schlagworte</td>
            <td className="ui-resource-meta-content">
              <ul className="ui-tag-cloud small">
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 1</a>
                </li>
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 2</a>
                </li>
              </ul>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Eigentumer/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Rechte</td>
            <td className="ui-resource-meta-content">unbekannt</td>
          </tr>
        </tbody>
      </table>
    </div>


Description = React.createClass
  displayName: 'Description'
  render: () ->
    <div className="ui-resource-description">
      <table className="borderless block">
        <tbody>
          <tr>
            <td className="ui-resource-meta-label">Autor/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Datierung</td>
            <td className="ui-resource-meta-content">1470/1500</td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Schlagworte</td>
            <td className="ui-resource-meta-content">
              <ul className="ui-tag-cloud small">
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 1</a>
                </li>
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 2</a>
                </li>
              </ul>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Eigentumer/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Rechte</td>
            <td className="ui-resource-meta-content">unbekannt</td>
          </tr>
        </tbody>
      </table>
    </div>

Extension = React.createClass
  displayName: 'Extension'
  render: () ->
    <div className="ui-resource-extension">
      <table className="borderless block">
        <tbody>
          <tr>
            <td className="ui-resource-meta-label">Autor/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Datierung</td>
            <td className="ui-resource-meta-content">1470/1500</td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Schlagworte</td>
            <td className="ui-resource-meta-content">
              <ul className="ui-tag-cloud small">
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 1</a>
                </li>
                <li className="ui-tag-cloud-item">
                  <a className="ui-tag-button" href="#">Tag 2</a>
                </li>
              </ul>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Eigentumer/in</td>
            <td className="ui-resource-meta-content">
              <a href="#">Federico C.</a>
            </td>
          </tr>
          <tr>
            <td className="ui-resource-meta-label">Rechte</td>
            <td className="ui-resource-meta-content">unbekannt</td>
          </tr>
        </tbody>
      </table>
    </div>
