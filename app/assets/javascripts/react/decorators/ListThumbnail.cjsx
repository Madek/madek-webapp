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
Thumbnail = require('../ui-components/Thumbnail.cjsx')

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


  render: ({resourceType, imageUrl, mediaType, title, subtitle, mediaUrl, metaData, selectProps} = @props) ->

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

    classes = {'ui-resource': true, 'ui-selected': true if (selectProps and selectProps.isSelected)}

    <li className={c(classes)} style={@props.style}>
      <div className="ui-resource-head">
        <h3 className="ui-resource-title">{title}</h3>
      </div>
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <div className={c('ui-thumbnail', thumbnailClass)}>
            <div className="ui-thumbnail-privacy">
              <i className="icon-privacy-group"></i>
            </div>
            <Image innerImage={innerImage} mediaUrl={mediaUrl} />
            <Titles />
          </div>
        </div>
        {
          if @props.loadingMetadata
            <Preloader />
          else
            f.map(listsWithClasses, (item, index) =>
              <div className={item.className} key={'list_' + index}>
                <MetaDataList showTitle={false} mods='ui-resource-meta' listMods='block' type='table'
                  list={item.list} renderer={@_listRenderer}/>
              </div>
            )
        }

      </div>
    </li>


Image = React.createClass
  displayName: 'Image'
  render: ({old, innerImage, mediaUrl} = @props) ->
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
