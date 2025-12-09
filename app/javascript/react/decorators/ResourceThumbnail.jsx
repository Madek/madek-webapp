/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React, { useState, useEffect, useCallback, useRef, memo } from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import ResourceThumbnailRenderer from './ResourceThumbnailRenderer.jsx'
import PinThumbnail from './PinThumbnail.jsx'
import ListThumbnail from './ListThumbnail.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import Picture from '../ui-components/Picture.jsx'
import BoxFetchRelations from './BoxFetchRelations.js'
import BoxFavorite from './BoxFavorite.js'
import BoxDelete from './BoxDelete.js'
import getMediaType from '../../models/shared/get-media-type.js'
import { cloneDeep, get as utilGet } from '../../lib/utils.js'

const CURSOR_SELECT_STYLE = { cursor: 'cell' }

const ResourceThumbnail = ({
  authToken,
  onSelect,
  fetchRelations,
  elm,
  get,
  isClient: isClientProp,
  onPictureClick,
  pictureLinkStyle,
  isSelected,
  pinThumb,
  listThumb,
  list_meta_data,
  uploadMediaType,
  style,
  positionProps
}) => {
  const [isClient, setIsClient] = useState(isClientProp || false)
  const [deleteModal, setDeleteModal] = useState(false)

  // Use refs for transition functions to avoid circular dependencies
  const relationsTransitionRef = useRef(null)
  const favoriteTransitionRef = useRef(null)

  // Initialize states with lazy initialization
  const [relationsState, setRelationsState] = useState(() => {
    const initial = BoxFetchRelations(null, { type: get.type }, ps => {
      if (relationsTransitionRef.current) {
        relationsTransitionRef.current(ps)
      }
    })
    return initial
  })

  const [favoriteState, setFavoriteState] = useState(() => {
    const initial = BoxFavorite(null, { resource: get }, ps => {
      if (favoriteTransitionRef.current) {
        favoriteTransitionRef.current(ps)
      }
    })
    return initial
  })

  // Define transition functions
  relationsTransitionRef.current = props => {
    const next = BoxFetchRelations(cloneDeep(relationsState), props, ps =>
      relationsTransitionRef.current(ps)
    )
    setRelationsState(next)
  }

  favoriteTransitionRef.current = props => {
    const next = BoxFavorite(cloneDeep(favoriteState), props, ps =>
      favoriteTransitionRef.current(ps)
    )
    setFavoriteState(next)
  }

  useEffect(() => {
    setIsClient(true)
  }, [])

  const [, forceUpdate] = useState({})
  useEffect(() => {
    const handleChange = () => forceUpdate({})
    if (get && get.on) {
      get.on('change', handleChange)
      return () => get.off('change', handleChange)
    }
  }, [get])

  const _fetchRelations = useCallback(() => {
    if (relationsTransitionRef.current) {
      relationsTransitionRef.current({
        event: 'try-fetch',
        resource: get
      })
    }
  }, [get])

  const _onHover = useCallback(() => {
    if (fetchRelations) {
      _fetchRelations()
    }
  }, [fetchRelations, _fetchRelations])

  const _favorOnClick = useCallback(() => {
    if (favoriteTransitionRef.current) {
      favoriteTransitionRef.current({ event: 'toggle', resource: get })
    }
  }, [get])

  const _showModal = useCallback(() => {
    setDeleteModal(true)
  }, [])

  const _onModalOk = useCallback(() => {
    BoxDelete(get, () => {
      location.reload()
    })
  }, [get])

  const _onModalCancel = useCallback(() => {
    setDeleteModal(false)
  }, [])

  const renderContent = () => {
    let childRelations, childrenCount, childThumbs, parentRelations, parentsCount, parentThumbs

    if (fetchRelations) {
      parentRelations = relationsState.relations.parents
      childRelations = relationsState.relations.children

      if (parentRelations) {
        parentsCount = parentRelations.pagination.total_count

        if (parentsCount > 0) {
          parentThumbs = utilGet(parentRelations, 'resources', []).map(item => (
            <li className="ui-thumbnail-level-item media_set set odd" key={item.uuid}>
              <a className="ui-level-image-wrapper" href={item.url}>
                <div className="ui-thumbnail-level-image-holder">
                  <FlyoutImage
                    resourceType={item.type}
                    title={item.title}
                    imageUrl={item.image_url}
                    mediaType={item.media_type}
                  />
                </div>
              </a>
            </li>
          ))
        }
      }

      if (childRelations) {
        childrenCount = childRelations.pagination.total_count

        if (childrenCount > 0) {
          childThumbs = utilGet(childRelations, 'resources', []).map(function (item) {
            let classes = 'ui-thumbnail-level-item media_set set odd'
            if (item.type === 'MediaEntry') {
              classes = 'ui-thumbnail-level-item media_entry image odd'
            }
            return (
              <li className={classes} key={item.uuid}>
                <a className="ui-level-image-wrapper" href={item.url}>
                  <div className="ui-thumbnail-level-image-holder">
                    <FlyoutImage
                      resourceType={item.type}
                      title={item.title}
                      imageUrl={item.image_url}
                      mediaType={item.media_type}
                    />
                  </div>
                </a>
              </li>
            )
          })
        }
      }
    }

    const relationsProps = {
      onHover: _onHover,
      parent: fetchRelations
        ? {
            ready: parentRelations ? true : undefined,
            count: parentRelations ? parentsCount : undefined,
            thumbs: parentThumbs ? parentThumbs : undefined
          }
        : undefined,
      child: fetchRelations
        ? {
            ready: childRelations ? true : undefined,
            count: childRelations ? childrenCount : undefined,
            thumbs: childThumbs ? childThumbs : undefined
          }
        : undefined
    }

    const favoriteProps = {
      pendingFavorite: favoriteState.pendingFavorite,
      favorOnClick: _favorOnClick,
      modelFavored: favoriteState.favored,
      favorUrl: get.favor_url,
      disfavorUrl: get.disfavor_url,
      stateIsClient: isClient,
      authToken,
      favoritePolicy: get.favorite_policy
    }

    const deleteProps = {
      stateDeleteModal: deleteModal,
      onModalCancel: _onModalCancel,
      onModalOk: _onModalOk,
      modalTitle: get.title,
      showModal: _showModal
    }

    const statusProps = {
      modelType: get.type,
      modelPublished: get.type === 'MediaEntry' ? get['published?'] : undefined,
      privacyStatus: get.privacy_status,
      onClipboard: get.on_clipboard ? true : undefined
    }

    const selectProps = {
      onSelect: onSelect,
      selectStyle: CURSOR_SELECT_STYLE,
      isSelected: isSelected
    }

    const getTextProps = () => {
      if (get.uploadStatus) {
        return {
          title: get.uploadStatus[0],
          subtitle: get.uploadStatus[1]
        }
      } else {
        return {
          title: get.title,
          subtitle: get.authors_pretty
        }
      }
    }

    const textProps = getTextProps()

    const resourceMediaType = uploadMediaType
      ? uploadMediaType
      : getMediaType(utilGet(get, 'media_file.content_type'))

    if (pinThumb) {
      return (
        <li
          style={style}
          className={cx('ui-resource', {
            'is-video': get.media_type === 'video',
            'ui-selected': selectProps && selectProps.isSelected
          })}>
          <PinThumbnail
            resourceType={get.type}
            imageUrl={utilGet(get, 'media_file.previews.images.large.url', get.image_url)}
            mediaType={resourceMediaType}
            title={textProps.title}
            subtitle={textProps.subtitle}
            mediaUrl={get.url}
            selectProps={selectProps}
            favoriteProps={favoriteProps}
            editable={get.editable}
            editUrl={get.edit_meta_data_by_context_url}
            destroyable={get.destroyable}
            deleteProps={deleteProps}
            statusProps={statusProps}
            style={style}
            onPictureClick={onPictureClick}
            pictureLinkStyle={pictureLinkStyle}
          />
        </li>
      )
    } else if (listThumb) {
      const classes = {
        'ui-resource': true,
        'ui-selected': selectProps && selectProps.isSelected ? true : undefined
      }
      return (
        <li className={cx(classes)} style={style}>
          <ListThumbnail
            resourceType={get.type}
            imageUrl={get.image_url}
            mediaType={resourceMediaType}
            title={textProps.title}
            subtitle={textProps.subtitle}
            mediaUrl={get.url}
            metaData={list_meta_data ? list_meta_data.meta_data : undefined}
            style={style}
            selectProps={selectProps}
            favoriteProps={favoriteProps}
            deleteProps={deleteProps}
            get={get}
            onPictureClick={onPictureClick}
            pictureLinkStyle={pictureLinkStyle}
            positionProps={positionProps}
          />
        </li>
      )
    } else {
      const Element = elm || 'div'
      const classes = {
        'ui-resource': true,
        'ui-selected': selectProps && selectProps.isSelected ? true : undefined
      }
      return (
        <Element
          style={style}
          className={cx(classes)}
          onMouseOver={relationsProps ? relationsProps.onHover : undefined}>
          <ResourceThumbnailRenderer
            resourceType={get.type}
            mediaType={resourceMediaType}
            elm={elm}
            get={get}
            relationsProps={relationsProps}
            favoriteProps={favoriteProps}
            deleteProps={deleteProps}
            statusProps={statusProps}
            selectProps={selectProps}
            textProps={textProps}
            style={style}
            onPictureClick={onPictureClick}
            pictureLinkStyle={pictureLinkStyle}
            positionProps={positionProps}
          />
        </Element>
      )
    }
  }

  return renderContent()
}

ResourceThumbnail.propTypes = {
  authToken: PropTypes.string,
  onSelect: PropTypes.func,
  fetchRelations: PropTypes.bool,
  elm: PropTypes.string,
  get: PropTypes.shape({
    type: PropTypes.oneOf(['MediaEntry', 'Collection'])
  }),
  resource: PropTypes.shape({
    type: PropTypes.oneOf(['MediaEntry'])
  })
}

const FlyoutImage = ({ imageUrl, title, mediaType, resourceType }) => {
  if (imageUrl) {
    return <Picture mods="ui-thumbnail-level-image" src={imageUrl} alt={title} />
  } else {
    return (
      <ResourceIcon
        mediaType={mediaType}
        flyout={true}
        type={resourceType}
        overrideClasses="ui-thumbnail-level-image"
      />
    )
  }
}

export default memo(ResourceThumbnail)
module.exports = memo(ResourceThumbnail)
