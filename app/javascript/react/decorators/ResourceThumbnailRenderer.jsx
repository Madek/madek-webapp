import React, { memo } from 'react'
import cx from 'classnames'
import { Link, Icon, Thumbnail, Button, Preloader } from '../ui-components/index.js'
import StatusIcon from './thumbnail/StatusIcon.jsx'
import FavoriteButton from './thumbnail/FavoriteButton.jsx'
import DeleteModal from './thumbnail/DeleteModal.jsx'
import { get as utilGet } from '../../lib/utils.js'

const ResourceThumbnailRenderer = ({
  resourceType,
  mediaType,
  get,
  onPictureClick,
  relationsProps,
  favoriteProps,
  deleteProps,
  statusProps,
  selectProps,
  textProps,
  positionProps,
  pictureLinkStyle
}) => {
  let statusIcon
  if (statusProps) {
    statusIcon = (
      <StatusIcon
        privacyStatus={statusProps.privacyStatus}
        resourceType={resourceType}
        modelPublished={statusProps.modelPublished}
      />
    )
  }

  // hover - actions
  const actionsLeft = []
  const actionsRight = []

  // hover - action - select
  if (selectProps && selectProps.onSelect) {
    const selectAction = (
      <li className="ui-thumbnail-action" key="selector">
        <span className="js-only">
          <Link
            onClick={selectProps.onSelect}
            style={selectProps.selectStyle}
            className="ui-thumbnail-action-checkbox"
            title={selectProps.isSelected ? 'Auswahl entfernen' : 'auswählen'}>
            <Icon i="checkbox" mods={selectProps.isSelected ? 'active' : undefined} />
          </Link>
        </span>
      </li>
    )
    actionsLeft.push(selectAction)
  }

  // hover - action - fav
  if (favoriteProps && favoriteProps.favoritePolicy) {
    const favorButton = (
      <FavoriteButton
        modelFavored={favoriteProps.modelFavored}
        favorUrl={favoriteProps.favorUrl}
        disfavorUrl={favoriteProps.disfavorUrl}
        favorOnClick={favoriteProps.favorOnClick}
        pendingFavorite={favoriteProps.pendingFavorite}
        stateIsClient={favoriteProps.stateIsClient}
        authToken={favoriteProps.authToken}
        buttonClass="ui-thumbnail-action-favorite"
      />
    )
    actionsLeft.push(
      <li key="favorite" className="ui-thumbnail-action">
        {favorButton}
      </li>
    )
  }

  // change position buttons
  if (utilGet(positionProps, 'changeable', false) && resourceType === 'MediaEntry') {
    const { handlePositionChange } = positionProps
    const commonCss = { cursor: positionProps.disabled ? 'not-allowed' : 'pointer' }
    const iconCssClass = cx({ mid: positionProps.disabled })

    actionsLeft.push(
      React.createElement(
        'li',
        {
          key: 'action01',
          className: 'ui-thumbnail-action mrn',
          style: commonCss,
          title: 'Move to the beginning',
          onClick(e) {
            return handlePositionChange(get.uuid, -2, e)
          }
        },
        <Icon i="move-left-first" className={iconCssClass} />
      )
    )

    actionsLeft.push(
      React.createElement(
        'li',
        {
          key: 'action02',
          className: 'ui-thumbnail-action mhn',
          style: commonCss,
          title: 'Move left',
          onClick(e) {
            return handlePositionChange(get.uuid, -1, e)
          }
        },
        <Icon i="move-left" className={iconCssClass} />
      )
    )

    actionsLeft.push(
      React.createElement(
        'li',
        {
          key: 'action03',
          className: 'ui-thumbnail-action mhn',
          style: commonCss,
          title: 'Move right',
          onClick(e) {
            return handlePositionChange(get.uuid, 1, e)
          }
        },
        <Icon i="move-right" className={iconCssClass} />
      )
    )

    actionsLeft.push(
      React.createElement(
        'li',
        {
          key: 'action04',
          className: 'ui-thumbnail-action mln',
          style: commonCss,
          title: 'Move to the end',
          onClick(e) {
            return handlePositionChange(get.uuid, 2, e)
          }
        },
        <Icon i="move-right-last" className={iconCssClass} />
      )
    )
  }

  if (get.editable) {
    actionsRight.push(
      <li key="edit" className="ui-thumbnail-action">
        <Button className="ui-thumbnail-action-favorite" href={get.edit_meta_data_by_context_url}>
          <i className="icon-pen" />
        </Button>
      </li>
    )
  }

  if (deleteProps && get.destroyable) {
    actionsRight.push(
      <li key="destroy" className="ui-thumbnail-action">
        <Button className="ui-thumbnail-action-favorite" onClick={deleteProps.showModal}>
          <i className="icon-trash" />
        </Button>
      </li>
    )
  }

  const thumbProps = {
    draft: statusProps.modelPublished === false,
    onClipboard: statusProps.onClipboard,
    clipboardUrl: get.clipboard_url,
    type: get.type,
    mods: mediaType === 'video' ? ['video'] : undefined,
    src: get.image_url,
    href: get.url,
    alt: get.title,
    mediaType,
    // click handlers:
    onPictureClick,
    pictureLinkStyle,
    // extra elements (nested for layout):
    meta: textProps,
    badgeLeft: statusIcon,
    badgeRight:
      get.type === 'FilterSet' ? <Icon i="filter" title="This is a Filterset" /> : undefined,
    actionsLeft,
    actionsRight,

    flyoutTop:
      relationsProps && relationsProps.parent && ['MediaEntry', 'Collection'].includes(resourceType)
        ? {
            title: 'Übergeordnete Sets',
            children: relationsProps.parent.ready ? (
              relationsProps.parent.thumbs
            ) : (
              <Preloader mods="small" />
            ),
            caption: relationsProps.parent.ready ? relationsProps.parent.count + ' Sets' : ''
          }
        : undefined,

    flyoutBottom:
      relationsProps && relationsProps.child && resourceType === 'Collection'
        ? {
            title: 'Set enthält',
            children: relationsProps.child.ready ? (
              relationsProps.child.thumbs
            ) : (
              <Preloader mods="small" />
            ),
            caption: relationsProps.child.ready ? relationsProps.child.count + ' Inhalte' : ''
          }
        : undefined,

    disableLink: get.disableLink,
    editMetaDataByContextUrl: get.edit_meta_data_by_context_url
  }

  return (
    <div className="ui-resource-body">
      <Thumbnail {...thumbProps} />
      {deleteProps && deleteProps.stateDeleteModal === true ? (
        <DeleteModal
          resourceType={get.type}
          onModalOk={deleteProps.onModalOk}
          onModalCancel={deleteProps.onModalCancel}
          modalTitle={deleteProps.modalTitle}
        />
      ) : null}
    </div>
  )
}

export default memo(ResourceThumbnailRenderer)
module.exports = memo(ResourceThumbnailRenderer)
