React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
ui = require('../lib/ui.coffee')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')
Picture = require('../ui-components/Picture.cjsx')
ResourceIcon = require('../ui-components/ResourceIcon.cjsx')
t = require('../../lib/i18n-translate.js')

flyoutProps = React.PropTypes.shape({
  title: React.PropTypes.string.isRequired,
  caption: React.PropTypes.string.isRequired,
  children: React.PropTypes.node })

module.exports = React.createClass
  displayName: 'Thumbnail'
  propTypes:
    type: React.PropTypes.oneOf(['MediaEntry', 'Collection']).isRequired
    src: React.PropTypes.string
    mediaType: React.PropTypes.string
    mods: PropTypes.arrayOf(PropTypes.oneOf(['video']))
    alt: React.PropTypes.string
    href: React.PropTypes.string
    privacy: React.PropTypes.string
    meta: React.PropTypes.shape
      title: React.PropTypes.string.isRequired
      subtitle: React.PropTypes.string
    actionsLeft: React.PropTypes.arrayOf(React.PropTypes.node)
    actionsRight: React.PropTypes.arrayOf(React.PropTypes.node)
    flyoutTop: flyoutProps
    flyoutBottom: flyoutProps

  render: () ->
    { type, src, alt, href, onPictureClick,
      meta, iconCenter, badgeRight, badgeLeft, actionsLeft, actionsRight,
      flyoutTop, flyoutBottom,
      mediaType,
      mods, className
    } = @props

    classes = ui.cx(
      f.kebabCase(type.replace(/Collection/, 'MediaSet')),
      [mods, className],
      'ui-thumbnail'
    )

    innerImage = if src
      <Picture mods='ui-thumbnail-image' src={src} alt={alt} />
    else
      <ResourceIcon mediaType={mediaType} thumbnail={true} type={type} />

    flyoutTop = if f.present(flyout = @props.flyoutTop)
      <div className='ui-thumbnail-level-up-items'>
        <h3 className='ui-thumbnail-level-notes'>{flyout.title}</h3>
        <ul className='ui-thumbnail-level-items'>
          {flyout.children}
        </ul>
        <span className='ui-thumbnail-level-notes'>{flyout.caption}</span>
      </div>

    flyoutBottom = if f.present(flyout = @props.flyoutBottom)
      <div className='ui-thumbnail-level-down-items'>
        <h3 className='ui-thumbnail-level-notes'>{flyout.title}</h3>
        <ul className='ui-thumbnail-level-items'>
          {flyout.children}
        </ul>
        <span className='ui-thumbnail-level-notes'>{flyout.caption}</span>
      </div>

    badgeLeft = if badgeLeft
      <div className='ui-thumbnail-privacy'>
        {badgeLeft}
      </div>

    bubbles = []

    if @props.draft
      bubbles.push({
        key: 'draft'
        label: t('bubble_draft_label')
        color: '#f99'
        href: @props.editMetaDataByContextUrl
      })

    if @props.onClipboard
      bubbles.push({
        key: 'batch'
        label: t('bubble_batch_label')
        color: '#99f'
        href: @props.clipboardUrl
      })


    bubbleElements =
      <div className='ui-bubbles'>
        {
          f.map(bubbles, (bubble, index) =>
            style = {
              backgroundColor: bubble.color
            }
            <a key={bubble.key} href={bubble.href} key={index}>
              <div className='ui-bubble' style={style}>{bubble.label}</div>
            </a>
          )
        }
      </div>

    useBubbles = false

    badgeRight = if badgeRight
      <div className='ui-thumbnail-filterset-flag'>
        {badgeRight}
      </div>

    metaElement = if meta
      <div className='ui-thumbnail-meta'>
        <h3 className='ui-thumbnail-meta-title'>
          {meta.title}</h3>
        <h4 className='ui-thumbnail-meta-subtitle'>
          {meta.subtitle}</h4>
      </div>


    actions = <div className='ui-thumbnail-actions'>
      <ul className='left by-left'>
        {actionsLeft}
      </ul>
      <ul className='right by-right'>
        {actionsRight}
      </ul>
    </div>


    innerPart =
      <div className='ui-thumbnail-image-holder'>
        <div className='ui-thumbnail-table-image-holder'>
          <div className='ui-thumbnail-cell-image-holder'>
            <div className='ui-thumbnail-inner-image-holder'>
              {innerImage}
            </div>
          </div>
        </div>
      </div>


    <div className={classes}>
      {flyoutTop}
      {badgeLeft}
      {badgeRight}
      {bubbleElements if useBubbles}
      {
        if @props.disableLink
          <div className='ui-thumbnail-image-wrapper'>{innerPart}</div>
        else
          <Link className='ui-thumbnail-image-wrapper' style={@props.pictureLinkStyle}
            href={@props.href} onClick={@props.onPictureClick} title={alt}>
            {innerPart}
          </Link>
      }
      {metaElement}
      {actions}
      {flyoutBottom}
    </div>
