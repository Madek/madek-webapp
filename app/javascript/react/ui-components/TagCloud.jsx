// Render a UI "Tag Cloud" from a list of tag *props*

import React from 'react'
import PropTypes from 'prop-types'
import cx from 'classnames'
import { parseMods } from '../lib/ui.js'
import { omit } from '../../lib/utils.js'
import Link from './Link.jsx'
import Icon from './Icon.jsx'

const TagCloud = props => {
  const { list, mod, mods } = props
  const baseClass = cx(parseMods(props), 'ui-tag-cloud')
  const itemClass = cx('ui-tag-cloud-item', { block: mod === 'role' })

  return (
    <ul
      className={baseClass}
      style={mods && mods.includes('inline') ? { display: 'inline-block' } : {}}>
      {list.map(listItem => {
        const itemProps = { ...omit(props, 'list'), ...listItem }
        const { count, children, mod, tag, href, disabled, onClick } = itemProps

        const linkProps = {
          href,
          disabled,
          onClick,
          className: cx('ui-tag-button', parseMods(itemProps))
        }

        const key = itemProps.key || JSON.stringify(listItem)

        let tagIcon
        switch (mod) {
          case 'label':
            tagIcon = 'tag'
            break
          case 'person':
            tagIcon = 'user'
            break
          case 'role':
            tagIcon = 'user'
            break
          case 'group':
            tagIcon = 'group'
            break
        }

        if (tagIcon && !(mods && mods.includes('large'))) {
          tagIcon = `${tagIcon}-mini` // mini variant except in large tags
        }

        const TagElm = tag || Link

        return (
          <li key={key} className={itemClass}>
            <TagElm {...linkProps}>
              {tagIcon && <Icon i={tagIcon} mods="ui-tag-icon" />}
              {children}
              {count && <span className="ui-tag-counter">{count}</span>}
            </TagElm>
          </li>
        )
      })}
    </ul>
  )
}

TagCloud.propTypes = {
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
}

export default TagCloud
module.exports = TagCloud
