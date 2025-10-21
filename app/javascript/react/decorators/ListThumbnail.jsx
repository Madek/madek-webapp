/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React, { memo } from 'react'
import cx from 'classnames'
import t from '../../lib/i18n-translate.js'
import Picture from '../ui-components/Picture.jsx'
import Button from '../ui-components/Button.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import Link from '../ui-components/Link.jsx'
import Icon from '../ui-components/Icon.jsx'
import FavoriteButton from './thumbnail/FavoriteButton.jsx'
import DeleteModal from './thumbnail/DeleteModal.jsx'
import MetaDataList from './MetaDataList.jsx'
import Preloader from '../ui-components/Preloader.jsx'
import MetaDataDefinitionList from './MetaDataDefinitionList.jsx'
import { kebabCase } from '../../lib/utils.js'

const ListThumbnail = ({
  resourceType,
  imageUrl,
  mediaType,
  title,
  mediaUrl,
  metaData,
  selectProps,
  favoriteProps,
  deleteProps,
  positionProps,
  get,
  onPictureClick,
  pictureLinkStyle
}) => {
  const { handlePositionChange } = positionProps

  const listsWithClasses = []

  if (metaData) {
    if (metaData.contexts_for_list_details.length > 0) {
      listsWithClasses.push({
        key: 'context_1',
        className: 'ui-resource-meta',
        list: metaData.contexts_for_list_details[0]
      })
    }
    if (metaData.contexts_for_list_details.length > 1) {
      listsWithClasses.push({
        key: 'context_2',
        className: 'ui-resource-description',
        list: metaData.contexts_for_list_details[1]
      })
    }
  }

  const usageData = {
    key: 'usage_data',
    className: 'ui-resource-extension ui-metadata-box',
    list: [
      // NOTE: <https://github.com/Madek/madek/issues/260>
      // {
      //   key: 'responsible',
      //   type: 'text',
      //   label: t('usage_data_responsible'),
      //   value: <TagCloud mod='person' mods='small' list={[{
      //       href: get.responsible.url
      //       children: get.responsible.name
      //       key:  get.responsible.uuid
      //     }]}></TagCloud>
      // },
      {
        key: 'created_at',
        type: 'text',
        label: t('usage_data_import_at'),
        value: get.created_at_pretty
      }
    ]
  }

  const iconStyle = {
    position: 'relative',
    top: '2px'
  }

  if (get.list_meta_data) {
    const { relation_counts } = get.list_meta_data

    if (relation_counts['parent_collections_count?']) {
      usageData.list.push({
        key: 'parents',
        type: 'text',
        label: t('usage_data_relations_parents'),
        value: (
          <span>
            {relation_counts.parent_collections_count} <Icon i="set" style={iconStyle} />
          </span>
        )
      })
    }

    if (
      relation_counts['child_collections_count?'] &&
      relation_counts['child_media_entries_count?']
    ) {
      usageData.list.push({
        key: 'children',
        type: 'text',
        label: t('usage_data_relations_children'),
        value: (
          <span>
            <span>
              {relation_counts.child_collections_count} <Icon i="set" style={iconStyle} />
            </span>
            <span style={{ marginLeft: '15px' }}>
              {relation_counts.child_media_entries_count} <Icon i="media-entry" style={iconStyle} />
            </span>
          </span>
        )
      })
    }
  }

  const innerImage = imageUrl ? (
    <Picture mods="ui-thumbnail-image" src={imageUrl} alt={title} />
  ) : (
    <ResourceIcon
      mediaType={mediaType}
      thumbnail={true}
      tiles={false}
      type={resourceType}
      overrideClasses="ui-thumbnail-image"
    />
  )

  const thumbnailClass = [
    kebabCase(resourceType.replace(/Collection/, 'MediaSet')),
    mediaType === 'video' ? 'video' : undefined
  ]

  const actionList = []

  const liStyle = {
    marginRight: '3px',
    padding: '2px'
  }

  if (selectProps && selectProps.onSelect) {
    const selectAction = (
      <li className="ui-thumbnail-action" key="selector" style={liStyle}>
        <span className="js-only">
          <Link
            onClick={selectProps.onSelect}
            style={selectProps.selectStyle}
            className="ui-thumbnail-action-checkbox"
            title={
              selectProps.isSelected
                ? t('resources_box_selection_remove_selection')
                : t('resources_box_selection_select')
            }>
            <Icon i="checkbox" mods={selectProps.isSelected ? 'active' : undefined} />
          </Link>
        </span>
      </li>
    )
    actionList.push(selectAction)
  }

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
    actionList.push(
      <li key="favorite" className="ui-thumbnail-action" style={liStyle}>
        {favorButton}
      </li>
    )
  }

  // change position buttons
  if (positionProps.changeable && resourceType === 'MediaEntry') {
    const commonCss = { ...liStyle, cursor: positionProps.disabled ? 'not-allowed' : 'pointer' }
    const iconCssClass = cx({ mid: positionProps.disabled })

    actionList.push(
      React.createElement(
        'li',
        {
          className: 'ui-thumbnail-action',
          style: commonCss,
          title: 'Move to the beginning',
          onClick(e) {
            return handlePositionChange(get.uuid, -2, e)
          }
        },
        <Icon i="move-up-first" className={iconCssClass} />
      )
    )

    actionList.push(
      React.createElement(
        'li',
        {
          className: 'ui-thumbnail-action',
          style: commonCss,
          title: 'Move up',
          onClick(e) {
            return handlePositionChange(get.uuid, -1, e)
          }
        },
        <Icon i="move-up" className={iconCssClass} />
      )
    )

    actionList.push(
      React.createElement(
        'li',
        {
          className: 'ui-thumbnail-action',
          style: commonCss,
          title: 'Move down',
          onClick(e) {
            return handlePositionChange(get.uuid, 1, e)
          }
        },
        <Icon i="move-down" className={iconCssClass} />
      )
    )

    actionList.push(
      React.createElement(
        'li',
        {
          className: 'ui-thumbnail-action',
          style: commonCss,
          title: 'Move to the end',
          onClick(e) {
            return handlePositionChange(get.uuid, 2, e)
          }
        },
        <Icon i="move-down-last" className={iconCssClass} />
      )
    )
  }

  if (get.editable) {
    actionList.push(
      <li key="edit" className="ui-thumbnail-action" style={liStyle}>
        <Button className="ui-thumbnail-action-favorite" href={get.edit_meta_data_by_context_url}>
          <i className="icon-pen" />
        </Button>
      </li>
    )
  }

  if (deleteProps && get.destroyable) {
    actionList.push(
      <li key="destroy" className="ui-thumbnail-action" style={liStyle}>
        <Button className="ui-thumbnail-action-favorite" onClick={deleteProps.showModal}>
          <i className="icon-trash" />
        </Button>
      </li>
    )
  }

  const actionsStyle = {
    left: '0px',
    top: '0px',
    right: 'auto',
    bottom: 'auto',
    height: '20px',
    width: `${actionList.length * 25 + 12}px`,
    position: 'static',
    float: 'left'
  }

  const actions = (
    <div className="ui-thumbnail-actions" style={actionsStyle}>
      <ul className="left by-left">{actionList}</ul>
    </div>
  )

  return (
    <div>
      <div className="ui-resource-head" style={{ marginLeft: '168px' }}>
        {actions}
        <h3 className="ui-resource-title">{title}</h3>
      </div>
      <div className="ui-resource-body">
        <div className="ui-resource-thumbnail">
          <div className={cx('ui-thumbnail', thumbnailClass)}>
            <div className="ui-thumbnail-privacy">
              <i className="icon-privacy-group" />
            </div>
            <Image
              onPictureClick={onPictureClick}
              pictureLinkStyle={pictureLinkStyle}
              innerImage={innerImage}
              mediaUrl={mediaUrl}
            />
            <Titles />
          </div>
        </div>
        {deleteProps && deleteProps.stateDeleteModal === true ? (
          <DeleteModal
            resourceType={get.type}
            onModalOk={deleteProps.onModalOk}
            onModalCancel={deleteProps.onModalCancel}
            modalTitle={deleteProps.modalTitle}
          />
        ) : null}
        {metaData ? (
          listsWithClasses
            .map(item => {
              return (
                <div className={item.className} key={item.key}>
                  <MetaDataList
                    showTitle={false}
                    mods="ui-resource-meta"
                    listMods="block"
                    type="list"
                    list={item.list}
                    listClasses="borderless block"
                    keyClasses="ui-resource-meta-label"
                    valueClasses="ui-resource-meta-content"
                  />
                </div>
              )
            })
            .concat(
              <div className={usageData.className} key={usageData.key}>
                <MetaDataDefinitionList
                  labelValuePairs={usageData.list}
                  fallbackMsg={null}
                  tagMods={null}
                />
              </div>
            )
        ) : (
          <Preloader />
        )}
      </div>
    </div>
  )
}

const Image = ({ innerImage, mediaUrl, onPictureClick, pictureLinkStyle }) => {
  return (
    <a
      className="ui-thumbnail-image-wrapper"
      onClick={onPictureClick}
      style={pictureLinkStyle}
      href={mediaUrl}>
      <div className="ui-thumbnail-image-holder">
        <div className="ui-thumbnail-table-image-holder">
          <div className="ui-thumbnail-cell-image-holder">
            <div className="ui-thumbnail-inner-image-holder">{innerImage}</div>
          </div>
        </div>
      </div>
    </a>
  )
}

const Titles = () => {
  return (
    <div className="ui-thumbnail-meta">
      <h3 className="ui-thumbnail-meta-title">Name that can easily go onto 2 lines</h3>
      <h4 className="ui-thumbnail-meta-subtitle">Author that can easily go onto 2 lines as well</h4>
    </div>
  )
}

export default memo(ListThumbnail)
module.exports = memo(ListThumbnail)
