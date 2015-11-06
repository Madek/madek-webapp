React = require('react')
f = require('active-lodash')
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')
Picture = require('./Picture.cjsx')
parseMods = require('../lib/parse-mods.coffee').fromProps

module.exports = React.createClass
  displayName: 'UiThumbnail'
  propTypes:
    type: React.PropTypes.oneOf(['media-entry', 'filter-set', 'media-set']).isRequired
    src: React.PropTypes.string.isRequired
    alt: React.PropTypes.string
    href: React.PropTypes.string
    privacy: React.PropTypes.string
    meta: React.PropTypes.shape
      title: React.PropTypes.string.isRequired
      subtitle: React.PropTypes.string

  render: ({type, src, alt, href, badgeRight, badgeLeft, meta} = @props)->
    classes = "ui-thumbnail #{type} #{parseMods(@props)}"

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


    <div className={classes}>
      {badgeLeft}
      {badgeRight}
      <Link className='ui-thumbnail-image-wrapper' href={href} title={alt}>
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
    </div>
