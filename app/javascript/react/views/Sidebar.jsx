import React from 'react'
import cx from 'classnames'
import libUrl from 'url'

const Sidebar = ({ sections, for_url }) => {
  const show_beta = false

  const endsWith = (string, suffix) => {
    return string.indexOf(suffix, string.length - suffix.length) !== -1
  }

  const sectionKeys = Object.keys(sections)

  return (
    <ul className="ui-side-navigation">
      {sectionKeys
        .map((section_id, index) => {
          const section = sections[section_id]
          const link = section.href

          if (!link) {
            throw new Error(`Missing href attribute for '${section_id}' section!`)
          }

          const link_active = endsWith(libUrl.parse(for_url).pathname, section_id)
          const classes = cx('ui-side-navigation-item', { active: link_active })
          const isLast = index === sectionKeys.length - 1

          return [
            <li className={classes} key={section_id}>
              <a className="strong" href={link}>
                {section.is_beta && show_beta && (
                  <em style={{ fontStyle: 'italic', fontWeight: 'normal' }}>Beta: </em>
                )}
                {section.title}
                {!!section.counter && (
                  <span
                    style={{ marginLeft: '4px', color: 'grey', fontWeight: 'normal' }}
                    id={`side-navigation-${section_id}-counter`}>
                    ({section.counter})
                  </span>
                )}
              </a>
            </li>,
            !isLast && <li key={section_id + 'key2'} className="separator mini" />
          ].filter(Boolean)
        })
        .flat()}
    </ul>
  )
}

export default Sidebar
module.exports = Sidebar
