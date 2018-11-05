# Render a UI "Tag Cloud" from a list of tag *props*

React = require('react')
f = require('active-lodash')
classList = require('classnames')
parseMods = require('../lib/ui.coffee').parseMods
UIPropTypes = require('../ui-components/propTypes.coffee')
Link = require('./Link.cjsx')
Icon = require('./Icon.cjsx')

module.exports = React.createClass
  displayName: 'TagCloud'
  propTypes:
    list: React.PropTypes.arrayOf(React.PropTypes.shape(
      children: React.PropTypes.node.isRequired
      key: React.PropTypes.string.isRequired
      href: React.PropTypes.string
      title: React.PropTypes.string
      count: React.PropTypes.string
      disabled: React.PropTypes.bool
    )).isRequired
    mod: React.PropTypes.oneOf(['label', 'person', 'group', 'role'])
    # TODO: mods: UIPropTypes.mods(['small', 'large', 'ellipsed', 'compact'])

  render: ({list, mod, mods} = @props)->
    baseClass = classList(parseMods(@props), 'ui-tag-cloud')
    itemClass = classList('ui-tag-cloud-item', { block: mod is 'role' })
    tagClass = 'ui-tag-button'
    tagIcon = switch mod
      when 'label'  then 'tag'
      when 'person' then 'user'
      when 'role' then 'user'
      when 'group'  then 'group'
    if tagIcon and !f.includes(mods, 'large')
      tagIcon = "#{tagIcon}-mini" # mini variant except in large tags

    <ul className={baseClass}>
      {list.map (tag)->
        props = f.merge(f.omit(@props, 'list'), tag)
        linkProps = f.pick(props, 'href', 'disabled', 'onClick')
        {count, children} = props
        key = props.key or JSON.stringify(tag)

        <li key={key} className={itemClass}>
          <Link {...linkProps} mods='ui-tag-button'>
            {if tagIcon
              <Icon i={tagIcon} mods='ui-tag-icon'/>}

            {children}

            {if count
              <span className='ui-tag-counter'>{count}</span>}
          </Link>
        </li>
      }
    </ul>
