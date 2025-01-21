/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Render a UI "Tag Cloud" from a list of tag *props*

import React from 'react'
import createReactClass from 'create-react-class'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import cx from 'classnames'
import { parseMods } from '../lib/ui.js'
import Link from './Link.jsx'
import Icon from './Icon.jsx'

module.exports = createReactClass({
  displayName: 'TagCloud',
  propTypes: {
    list: PropTypes.arrayOf(
      PropTypes.shape({
        children: PropTypes.node.isRequired,
        key: PropTypes.string,
        href: PropTypes.string,
        title: PropTypes.string,
        count: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
        disabled: PropTypes.bool
      })
    ).isRequired,
    mod: PropTypes.oneOf(['label', 'person', 'group', 'role'])
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { list, mod, mods } = param
    const baseClass = cx(parseMods(this.props), 'ui-tag-cloud')
    const itemClass = cx('ui-tag-cloud-item', { block: mod === 'role' })

    return (
      <ul
        className={baseClass}
        style={f.includes(mods, 'inline') ? { display: 'inline-block' } : {}}>
        {list.map(function(listItem) {
          const props = f.merge(f.omit(param, 'list'), listItem)
          const { count, children, mod, tag } = props
          const linkProps = f.merge(f.pick(props, 'href', 'disabled', 'onClick'), {
            className: cx('ui-tag-button', parseMods(props))
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
