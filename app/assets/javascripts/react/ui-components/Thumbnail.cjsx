React = require('react')
PropTypes = React.PropTypes
f = require('active-lodash')
ui = require('../lib/ui.coffee')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')
Picture = require('./Picture.cjsx')

flyoutProps = React.PropTypes.shape({
  title: React.PropTypes.string.isRequired,
  caption: React.PropTypes.string.isRequired,
  children: React.PropTypes.node })

module.exports = React.createClass
  displayName: 'UiThumbnail'
  propTypes:
    type: React.PropTypes.oneOf(['media-entry', 'filter-set', 'media-set']).isRequired
    src: React.PropTypes.string.isRequired
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
    { type, src, alt, href, onClick, meta,
      meta, badgeRight, badgeLeft, actionsLeft, actionsRight,
      flyoutTop, flyoutBottom
    } = @props

    classes = ui.cx(type, ui.parseMods(@props), 'ui-thumbnail')

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

    badgeRight = if badgeRight
      <div className='ui-thumbnail-filterset-flag'>
        {badgeRight}
      </div>

    meta = if meta
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

    # TODO: We probably only need 'href' and 'onClick'.
    linkProps = f.omit(@props, 'className')

    <div className={classes}>
      {flyoutTop}
      {badgeLeft}
      {badgeRight}
      <Link className='ui-thumbnail-image-wrapper' {...linkProps} title={alt}>
        <div className='ui-thumbnail-image-holder'>
          <div className='ui-thumbnail-table-image-holder'>
            <div className='ui-thumbnail-cell-image-holder'>
              <div className='ui-thumbnail-inner-image-holder'>
                <Picture mods='ui-thumbnail-image' src={src} alt={alt}/>
              </div>
            </div>
          </div>
        </div>
      </Link>
      {meta}
      {actions}
      {flyoutBottom}
    </div>
