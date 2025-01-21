/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import ui from '../lib/ui.js'
import Link from './Link.jsx'
import Picture from '../ui-components/Picture.jsx'
import ResourceIcon from '../ui-components/ResourceIcon.jsx'
import t from '../../lib/i18n-translate.js'

const flyoutProps = PropTypes.shape({
  title: PropTypes.string.isRequired,
  caption: PropTypes.string.isRequired,
  children: PropTypes.node
})

module.exports = createReactClass({
  displayName: 'Thumbnail',
  propTypes: {
    type: PropTypes.oneOf(['MediaEntry', 'Collection']).isRequired,
    src: PropTypes.string,
    mediaType: PropTypes.string,
    mods: PropTypes.arrayOf(PropTypes.oneOf(['video'])),
    alt: PropTypes.string,
    href: PropTypes.string,
    privacy: PropTypes.string,
    meta: PropTypes.shape({
      title: PropTypes.string.isRequired,
      subtitle: PropTypes.string
    }),
    actionsLeft: PropTypes.arrayOf(PropTypes.node),
    actionsRight: PropTypes.arrayOf(PropTypes.node),
    flyoutTop: flyoutProps,
    flyoutBottom: flyoutProps
  },

  render() {
    let flyout
    let {
      type,
      src,
      alt,
      meta,
      badgeRight,
      badgeLeft,
      actionsLeft,
      actionsRight,
      flyoutTop,
      flyoutBottom,
      mediaType,
      mods,
      className
    } = this.props

    const classes = ui.cx(
      f.kebabCase(type.replace(/Collection/, 'MediaSet')),
      [mods, className],
      'ui-thumbnail'
    )

    const innerImage = src ? (
      <Picture mods="ui-thumbnail-image" src={src} alt={alt} />
    ) : (
      <ResourceIcon mediaType={mediaType} thumbnail={true} type={type} />
    )

    flyoutTop = f.present((flyout = this.props.flyoutTop)) ? (
      <div className="ui-thumbnail-level-up-items">
        <h3 className="ui-thumbnail-level-notes">{flyout.title}</h3>
        <ul className="ui-thumbnail-level-items">{flyout.children}</ul>
        <span className="ui-thumbnail-level-notes">{flyout.caption}</span>
      </div>
    ) : (
      undefined
    )

    flyoutBottom = f.present((flyout = this.props.flyoutBottom)) ? (
      <div className="ui-thumbnail-level-down-items">
        <h3 className="ui-thumbnail-level-notes">{flyout.title}</h3>
        <ul className="ui-thumbnail-level-items">{flyout.children}</ul>
        <span className="ui-thumbnail-level-notes">{flyout.caption}</span>
      </div>
    ) : (
      undefined
    )

    badgeLeft = badgeLeft ? <div className="ui-thumbnail-privacy">{badgeLeft}</div> : undefined

    const bubbles = []

    if (this.props.draft) {
      bubbles.push({
        key: 'draft',
        label: t('bubble_draft_label'),
        color: '#f99',
        href: this.props.editMetaDataByContextUrl
      })
    }

    if (this.props.onClipboard) {
      bubbles.push({
        key: 'batch',
        label: t('bubble_batch_label'),
        color: '#99f',
        href: this.props.clipboardUrl
      })
    }

    const bubbleElements = (
      <div className="ui-bubbles">
        {f.map(bubbles, (bubble, index) => {
          const style = {
            backgroundColor: bubble.color
          }
          return (
            <a href={bubble.href} key={index}>
              <div className="ui-bubble" style={style}>
                {bubble.label}
              </div>
            </a>
          )
        })}
      </div>
    )

    const useBubbles = false

    badgeRight = badgeRight ? (
      <div className="ui-thumbnail-filterset-flag">{badgeRight}</div>
    ) : (
      undefined
    )

    const metaElement = meta ? (
      <div className="ui-thumbnail-meta">
        <h3 className="ui-thumbnail-meta-title">{meta.title}</h3>
        <h4 className="ui-thumbnail-meta-subtitle">{meta.subtitle}</h4>
      </div>
    ) : (
      undefined
    )

    const actions = (
      <div className="ui-thumbnail-actions">
        <ul className="left by-left">{actionsLeft}</ul>
        <ul className="right by-right">{actionsRight}</ul>
      </div>
    )

    const innerPart = (
      <div className="ui-thumbnail-image-holder">
        <div className="ui-thumbnail-table-image-holder">
          <div className="ui-thumbnail-cell-image-holder">
            <div className="ui-thumbnail-inner-image-holder">{innerImage}</div>
          </div>
        </div>
      </div>
    )

    return (
      <div className={classes}>
        {flyoutTop}
        {badgeLeft}
        {badgeRight}
        {useBubbles ? bubbleElements : undefined}
        {this.props.disableLink ? (
          <div className="ui-thumbnail-image-wrapper">{innerPart}</div>
        ) : (
          <Link
            className="ui-thumbnail-image-wrapper"
            style={this.props.pictureLinkStyle}
            href={this.props.href}
            onClick={this.props.onPictureClick}
            title={alt}>
            {innerPart}
          </Link>
        )}
        {metaElement}
        {actions}
        {flyoutBottom}
      </div>
    )
  }
})
