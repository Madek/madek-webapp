/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import l from 'lodash'
import cx from 'classnames'
import ampersandReactMixin from 'ampersand-react-mixin'
import ResourceThumbnailRenderer from './ResourceThumbnailRenderer.jsx'
import PinThumbnail from './PinThumbnail.jsx'
import ListThumbnail from './ListThumbnail.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import Picture from '../ui-components/Picture.jsx'
import BoxFetchRelations from './BoxFetchRelations.js'
import BoxFavorite from './BoxFavorite.js'
import BoxDelete from './BoxDelete.js'
import getMediaType from '../../models/shared/get-media-type.js'

const CURSOR_SELECT_STYLE = { cursor: 'cell' }

module.exports = createReactClass({
  displayName: 'ResourceThumbnail',
  mixins: [ampersandReactMixin],
  propTypes: {
    authToken: PropTypes.string,
    onSelect: PropTypes.func,
    fetchRelations: PropTypes.bool,
    elm: PropTypes.string, // type of html node of outer wrapper
    get: PropTypes.shape({
      type: PropTypes.oneOf(['MediaEntry', 'Collection'])
    }),
    resource: PropTypes.shape({
      type: PropTypes.oneOf(['MediaEntry'])
    })
  },

  shouldComponentUpdate(nextProps, nextState) {
    return !l.isEqual(this.state, nextState) || !l.isEqual(this.props, nextProps)
  },

  relationsTrigger(props) {
    return this.relationsTransition(props)
  },

  relationsInitial(props) {
    return BoxFetchRelations(null, props, ps => this.relationsTrigger(ps))
  },

  relationsTransition(props) {
    const next = BoxFetchRelations(f.cloneDeep(this.state.relationsState), props, ps =>
      this.relationsTrigger(ps)
    )
    return this.setState({ relationsState: next })
  },

  favoriteTrigger(props) {
    return this.favoriteTransition(props)
  },

  favoriteInitial(props) {
    return BoxFavorite(null, props, ps => this.favoriteTrigger(ps))
  },

  favoriteTransition(props) {
    const next = BoxFavorite(f.cloneDeep(this.state.favoriteState), props, ps =>
      this.favoriteTrigger(ps)
    )
    return this.setState({ favoriteState: next })
  },

  getInitialState() {
    return {
      isClient: this.props.isClient || false,
      deleteModal: false,
      relationsState: this.relationsInitial({ type: this.props.get.type }),
      favoriteState: this.favoriteInitial({ resource: this.props.get })
    }
  },

  componentDidMount() {
    return this.setState({ isClient: true })
  },

  _fetchRelations() {
    return this.relationsTransition({
      event: 'try-fetch',
      resource: this.props.get
    })
  },

  _onHover() {
    if (this.props.fetchRelations) {
      return this._fetchRelations()
    }
  },

  _favorOnClick() {
    return this.favoriteTransition({ event: 'toggle', resource: this.props.get })
  },

  _showModal() {
    return this.setState({ deleteModal: true })
  },

  _onModalOk() {
    return BoxDelete(this.props.get, () => {
      return location.reload()
    })
  },

  _onModalCancel() {
    return this.setState({ deleteModal: false })
  },

  render(param, state) {
    let childRelations,
      childrenCount,
      childThumbs,
      classes,
      parentRelations,
      parentsCount,
      parentThumbs
    if (param == null) {
      param = this.props
    }
    const { get, elm, fetchRelations, authToken, positionProps } = param
    if (state == null) {
      ;({ state } = this)
    }
    if (fetchRelations) {
      parentRelations = this.state.relationsState.relations.parents
      childRelations = this.state.relationsState.relations.children

      if (parentRelations) {
        parentsCount = parentRelations.pagination.total_count

        if (parentsCount > 0) {
          parentThumbs = f.get(parentRelations, 'resources').map(item => (
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
          childThumbs = f.get(childRelations, 'resources').map(function(item) {
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
      onHover: this._onHover,
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
      pendingFavorite: this.state.favoriteState.pendingFavorite,
      favorOnClick: this._favorOnClick,
      modelFavored: this.state.favoriteState.favored,
      favorUrl: get.favor_url,
      disfavorUrl: get.disfavor_url,
      stateIsClient: state.isClient,
      authToken,
      favoritePolicy: get.favorite_policy
    }

    const deleteProps = {
      stateDeleteModal: this.state.deleteModal,
      onModalCancel: this._onModalCancel,
      onModalOk: this._onModalOk,
      modalTitle: this.props.get.title,
      showModal: this._showModal
    }

    const statusProps = {
      modelType: this.props.get.type,
      modelPublished:
        this.props.get.type === 'MediaEntry' ? this.props.get['published?'] : undefined,
      privacyStatus: get.privacy_status,
      onClipboard: this.props.get.on_clipboard ? true : undefined
    }

    const selectProps = {
      onSelect: this.props.onSelect,
      selectStyle: CURSOR_SELECT_STYLE,
      isSelected: this.props.isSelected
    }

    const getTextProps = () => {
      const getTitle = () => {
        if (this.props.overrideTexts && this.props.overrideTexts.title) {
          return this.props.overrideTexts.title
        } else {
          return get.title
        }
      }

      const getSubtitle = () => {
        if (this.props.overrideTexts && this.props.overrideTexts.subtitle) {
          return this.props.overrideTexts.subtitle
        } else {
          return get.authors_pretty
        }
      }

      if (get.uploadStatus) {
        return {
          title: get.uploadStatus[0],
          subtitle: get.uploadStatus[1]
        }
      } else {
        return {
          title: getTitle(),
          subtitle: getSubtitle()
        }
      }
    }

    const textProps = getTextProps()

    const resourceMediaType = this.props.uploadMediaType
      ? this.props.uploadMediaType
      : getMediaType(f.get(this.props.get, 'media_file.content_type'))

    if (this.props.pinThumb) {
      return (
        <li
          style={this.props.style}
          className={cx('ui-resource', {
            'is-video': get.media_type === 'video',
            'ui-selected': selectProps && selectProps.isSelected
          })}>
          {this.props.batchApplyButton}
          <PinThumbnail
            resourceType={this.props.get.type}
            imageUrl={f.get(get, 'media_file.previews.images.large.url', get.image_url)}
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
            style={this.props.style}
            onPictureClick={this.props.onPictureClick}
            pictureLinkStyle={this.props.pictureLinkStyle}
          />
        </li>
      )
    } else if (this.props.listThumb) {
      classes = {
        'ui-resource': true,
        'ui-selected': selectProps && selectProps.isSelected ? true : undefined
      }
      return (
        <li className={cx(classes)} style={this.props.style}>
          {this.props.batchApplyButton}
          <ListThumbnail
            resourceType={this.props.get.type}
            imageUrl={get.image_url}
            mediaType={resourceMediaType}
            title={textProps.title}
            subtitle={textProps.subtitle}
            mediaUrl={get.url}
            metaData={this.props.list_meta_data ? this.props.list_meta_data.meta_data : undefined}
            style={this.props.style}
            selectProps={selectProps}
            favoriteProps={favoriteProps}
            deleteProps={deleteProps}
            get={get}
            onPictureClick={this.props.onPictureClick}
            pictureLinkStyle={this.props.pictureLinkStyle}
            positionProps={positionProps}
          />
        </li>
      )
    } else {
      const Element = elm || 'div'
      classes = {
        'ui-resource': true,
        'ui-selected': selectProps && selectProps.isSelected ? true : undefined
      }
      return (
        <Element
          style={this.props.style}
          className={cx(classes)}
          onMouseOver={relationsProps ? relationsProps.onHover : undefined}>
          {this.props.batchApplyButton}
          <ResourceThumbnailRenderer
            resourceType={this.props.get.type}
            mediaType={resourceMediaType}
            elm={elm}
            get={get}
            relationsProps={relationsProps}
            favoriteProps={favoriteProps}
            deleteProps={deleteProps}
            statusProps={statusProps}
            selectProps={selectProps}
            textProps={textProps}
            style={this.props.style}
            onPictureClick={this.props.onPictureClick}
            pictureLinkStyle={this.props.pictureLinkStyle}
            positionProps={positionProps}
          />
        </Element>
      )
    }
  }
})

var FlyoutImage = createReactClass({
  displayName: 'FlyoutImage',

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { imageUrl, title, mediaType, resourceType } = param
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
})
