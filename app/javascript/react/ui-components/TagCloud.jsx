/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Render a UI "Tag Cloud" from a list of tag *props*

const React = require('react')
const f = require('active-lodash')
const classList = require('classnames')
const { parseMods } = require('../lib/ui.js')
const UIPropTypes = require('../ui-components/propTypes.js')
const Link = require('./Link.cjsx')
const Icon = require('./Icon.cjsx')

module.exports = React.createClass({
  displayName: 'TagCloud',
  propTypes: {
    list: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        children: React.PropTypes.node.isRequired,
        key: React.PropTypes.string,
        href: React.PropTypes.string,
        title: React.PropTypes.string,
        count: React.PropTypes.string,
        disabled: React.PropTypes.bool
      })
    ).isRequired,
    mod: React.PropTypes.oneOf(['label', 'person', 'group', 'role'])
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { list, mod, mods } = param
    const baseClass = classList(parseMods(this.props), 'ui-tag-cloud')
    const itemClass = classList('ui-tag-cloud-item', { block: mod === 'role' })
    const tagClass = 'ui-tag-button'

    return (
      <ul
        className={baseClass}
        style={f.includes(mods, 'inline') ? { display: 'inline-block' } : {}}>
        {list.map(function(listItem) {
          let children, count, tag
          const props = f.merge(f.omit(this.props, 'list'), listItem)
          ;({ count, children, mod, tag } = props)
          const linkProps = f.merge(f.pick(props, 'href', 'disabled', 'onClick'), {
            className: classList('ui-tag-button', parseMods(props))
          })
          const key = props.key || JSON.stringify(listItem)
          let tagIcon = (() => {
            switch (mod) {
              case 'label':
                return 'tag'
              case 'person':
                return 'user'
              case 'role':
                return 'user'
              case 'group':
                return 'group'
            }
          })()
          if (tagIcon && !f.includes(mods, 'large')) {
            tagIcon = `${tagIcon}-mini` // mini variant except in large tags
          }

          const TagElm = tag || Link

          return (
            <li key={key} className={itemClass}>
              <TagElm {...Object.assign({}, linkProps)}>
                {tagIcon ? <Icon i={tagIcon} mods="ui-tag-icon" /> : undefined}
                {children}
                {count ? <span className="ui-tag-counter">{count}</span> : undefined}
              </TagElm>
            </li>
          )
        })}
      </ul>
    )
  }
})
