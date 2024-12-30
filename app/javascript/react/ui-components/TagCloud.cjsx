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
      key: React.PropTypes.string
      href: React.PropTypes.string
      title: React.PropTypes.string
      count: React.PropTypes.string
      disabled: React.PropTypes.bool
    )).isRequired
    mod: React.PropTypes.oneOf(['label', 'person', 'group', 'role'])

  render: ({list, mod, mods} = @props)->
    baseClass = classList(parseMods(@props), 'ui-tag-cloud')
    itemClass = classList('ui-tag-cloud-item', { block: mod is 'role' })
    tagClass = 'ui-tag-button'

    <ul
      className={baseClass}
      style={if f.includes(mods, 'inline') then {display:'inline-block'} else {}}
    >
      {list.map (listItem)->
        props = f.merge(f.omit(@props, 'list'), listItem)
        {count, children, mod, tag} = props
        linkProps = f.merge(
          f.pick(props, 'href', 'disabled', 'onClick'),
          { className: classList('ui-tag-button', parseMods(props)) }
        )
        key = props.key or JSON.stringify(listItem)
        tagIcon = switch mod
          when 'label'  then 'tag'
          when 'person' then 'user'
          when 'role' then 'user'
          when 'group'  then 'group'
        if tagIcon and !f.includes(mods, 'large')
          tagIcon = "#{tagIcon}-mini" # mini variant except in large tags

        TagElm = tag || Link

        <li key={key} className={itemClass}>
          <TagElm {...linkProps}>
            {if tagIcon
              <Icon i={tagIcon} mods='ui-tag-icon'/>}

            {children}

            {if count
              <span className='ui-tag-counter'>{count}</span>}
          </TagElm>
        </li>
      }
    </ul>
