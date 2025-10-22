import React from 'react'
import PropTypes from 'prop-types'
import { present } from '../../lib/utils.js'
import { kebabCase } from '../../lib/utils.js'
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

const Thumbnail = ({
  type,
  src,
  alt,
  meta,
  badgeRight: badgeRightProp,
  badgeLeft: badgeLeftProp,
  actionsLeft,
  actionsRight,
  flyoutTop: flyoutTopProp,
  flyoutBottom: flyoutBottomProp,
  mediaType,
  mods,
  className,
  draft,
  editMetaDataByContextUrl,
  onClipboard,
  clipboardUrl,
  disableLink,
  pictureLinkStyle,
  href,
  onPictureClick
}) => {
  const classes = ui.cx(
    kebabCase(type.replace(/Collection/, 'MediaSet')),
    [mods, className],
    'ui-thumbnail'
  )

  const innerImage = src ? (
    <Picture mods="ui-thumbnail-image" src={src} alt={alt} />
  ) : (
    <ResourceIcon mediaType={mediaType} thumbnail={true} type={type} />
  )

  const flyoutTop = present(flyoutTopProp) ? (
    <div className="ui-thumbnail-level-up-items">
      <h3 className="ui-thumbnail-level-notes">{flyoutTopProp.title}</h3>
      <ul className="ui-thumbnail-level-items">{flyoutTopProp.children}</ul>
      <span className="ui-thumbnail-level-notes">{flyoutTopProp.caption}</span>
    </div>
  ) : undefined

  const flyoutBottom = present(flyoutBottomProp) ? (
    <div className="ui-thumbnail-level-down-items">
      <h3 className="ui-thumbnail-level-notes">{flyoutBottomProp.title}</h3>
      <ul className="ui-thumbnail-level-items">{flyoutBottomProp.children}</ul>
      <span className="ui-thumbnail-level-notes">{flyoutBottomProp.caption}</span>
    </div>
  ) : undefined

  const badgeLeft = badgeLeftProp ? (
    <div className="ui-thumbnail-privacy">{badgeLeftProp}</div>
  ) : undefined

  const bubbles = []

  if (draft) {
    bubbles.push({
      key: 'draft',
      label: t('bubble_draft_label'),
      color: '#f99',
      href: editMetaDataByContextUrl
    })
  }

  if (onClipboard) {
    bubbles.push({
      key: 'batch',
      label: t('bubble_batch_label'),
      color: '#99f',
      href: clipboardUrl
    })
  }

  const bubbleElements = (
    <div className="ui-bubbles">
      {bubbles.map((bubble, index) => {
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

  const badgeRight = badgeRightProp ? (
    <div className="ui-thumbnail-filterset-flag">{badgeRightProp}</div>
  ) : undefined

  const metaElement = meta ? (
    <div className="ui-thumbnail-meta">
      <h3 className="ui-thumbnail-meta-title">{meta.title}</h3>
      <h4 className="ui-thumbnail-meta-subtitle">{meta.subtitle}</h4>
    </div>
  ) : undefined

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
      {disableLink ? (
        <div className="ui-thumbnail-image-wrapper">{innerPart}</div>
      ) : (
        <Link
          className="ui-thumbnail-image-wrapper"
          style={pictureLinkStyle}
          href={href}
          onClick={onPictureClick}
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

Thumbnail.propTypes = {
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
}

export default Thumbnail
module.exports = Thumbnail
