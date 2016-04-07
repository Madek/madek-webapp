React = require('react')
f = require('active-lodash')
parseMods = require('../lib/parse-mods.coffee').fromProps
Icon = require('./Icon.cjsx')
Link = require('./Link.cjsx')
Picture = require('./Picture.cjsx')


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


  render: ({type, src, alt, href, badgeRight, badgeLeft, actionsLeft, actionsRight, showRelations, parentsCount, childrenCount, parentRelations, childRelations, meta} = @props) ->

    classes = "ui-thumbnail #{type} #{parseMods(@props)}"

    parentsCountText = parentsCount + ' Sets'
    childrenCountText = childrenCount + ' Inhalte'

    parentsElement = null
    if @props.showRelations
      parentsElement =
        <div className="ui-thumbnail-level-up-items">
          <h3 className="ui-thumbnail-level-notes">Übergeordnete Sets</h3>
          <ul className="ui-thumbnail-level-items">
            {parentRelations}
          </ul>
          <span className="ui-thumbnail-level-notes">{parentsCountText}</span>
        </div>

    childrenElement = null
    if @props.showRelations
      childrenElement =
        <div className="ui-thumbnail-level-down-items">
          <h3 className="ui-thumbnail-level-notes">Set enthält</h3>
          <ul className="ui-thumbnail-level-items">
            {childRelations}
          </ul>
          <span className="ui-thumbnail-level-notes">{childrenCountText}</span>
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

    <div className={classes}>
      {parentsElement}
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
      {actions}
      {childrenElement}
    </div>
