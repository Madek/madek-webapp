import React from 'react'
import f from 'active-lodash'
import l from 'lodash'
import ActionsDropdownHelper from './resourcesbox/ActionsDropdownHelper.jsx'
import ResourceThumbnail from './ResourceThumbnail.jsx'

class BoxRenderResource extends React.Component {
  constructor(props) {
    super(props)
    this.boundOnSelect = this.onSelect.bind(this)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  }

  onSelect(event) {
    this.props.onSelectResource(this.props.resourceState.data.resource, event)
  }

  render() {
    var itemState = this.props.resourceState
    var isClient = this.props.isClient
    var config = this.props.config
    var hoverMenuId = this.props.hoverMenuId
    var fetchRelations = this.props.fetchRelations
    var authToken = this.props.authToken
    const { positionProps } = this.props

    var item = itemState.data.resource

    if (!item.uuid) {
      // should not be the case anymore after uploader is not using this box anymore
      throw new Error('no uuid')
    }

    var key = item.uuid // or item.cid

    var pictureLinkStyle = null

    var style = null
    // selection defined means selection is enabled
    var showActions = this.props.showActions
    if (isClient && f.any(f.values(showActions))) {
      var isSelected = this.props.isSelected
      var onSelect = this.boundOnSelect
      // if in selection mode, intercept clicks as 'select toggle'
      var onPictureClick = null
      if (config.layout == 'miniature') {
        // && selection.length > 0) {
        onPictureClick = onSelect
        pictureLinkStyle = { cursor: 'cell' }
      }

      //  when hightlighting editables, we just dim everything else:
      if (ActionsDropdownHelper.isResourceNotInScope(item, isSelected, hoverMenuId)) {
        style = { opacity: 0.35 }
      }
    }

    var overrideTexts = () => {
      var metaData = itemState.data.thumbnailMetaData
      if (!metaData) {
        return null
      }

      var getTitle = () => {
        if (metaData.title) {
          return metaData.title
        } else {
          return null
        }
      }

      var getSubtitle = () => {
        if (metaData.authors) {
          return metaData.authors
        } else {
          return null
        }
      }

      return {
        title: getTitle(),
        subtitle: getSubtitle()
      }
    }

    return (
      <ResourceThumbnail
        elm="div"
        style={style}
        get={item}
        overrideTexts={overrideTexts()}
        isClient={isClient}
        fetchRelations={fetchRelations}
        isSelected={isSelected}
        onSelect={onSelect}
        onPictureClick={onPictureClick}
        pictureLinkStyle={pictureLinkStyle}
        positionProps={positionProps}
        authToken={authToken}
        key={key}
        pinThumb={config.layout == 'tiles'}
        listThumb={config.layout == 'list'}
        list_meta_data={itemState.data.listMetaData}
        trigger={this.props.trigger}
      />
    )
  }
}

module.exports = BoxRenderResource
