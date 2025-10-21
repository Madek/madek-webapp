import React from 'react'
import HeaderButton from './HeaderButton.jsx'
import PageContentHeader from './PageContentHeader.jsx'
import Dropdown, { Menu, MenuItem } from '../ui-components/Dropdown.jsx'
import Icon from '../ui-components/Icon.jsx'
import Link from '../ui-components/Link.jsx'
import t from '../../lib/i18n-translate.js'
import { present } from '../../lib/utils.js'

class MediaEntryHeader extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      active: this.props.isClient
    }
  }

  _onClick = asyncAction => {
    if (this.props.onClick) {
      return this.props.onClick(asyncAction)
    }
  }

  render() {
    const { authToken, get } = this.props
    const icon = get.type === 'Collection' ? 'set' : 'media-entry'

    const buttons = get.button_actions
      .map(button_id => get.buttons.find(b => b.id === button_id))
      .filter(Boolean)

    const menuItems = get.dropdown_actions
      .map(button_id => get.buttons.find(b => b.id === button_id))
      .filter(Boolean)

    const banner =
      get.new_version_entries && get.new_version_entries.length > 0 ? (
        <div className="ui-alert warning ui-container inverted paragraph-l mbm">
          {t('media_entry_notice_new_versions')}
          <ul>
            {get.new_version_entries.map((i, idx) => {
              const me = i.entry
              const desc = present(i.description) ? i.description + ', ' : ''
              return (
                <li key={idx}>
                  <Link
                    href={me.url}
                    mods="strong"
                    style={{ color: '#adc671', textDecoration: 'underline' }}>
                    {me.title}
                  </Link>{' '}
                  <em style={{ fontStyle: 'italic' }}>
                    ({desc}
                    {me.date})
                  </em>
                </li>
              )
            })}
          </ul>
        </div>
      ) : undefined

    return (
      <PageContentHeader
        icon={icon}
        title={get.title}
        workflow={get.workflow}
        banner={banner}
        sectionLabels={get.section_labels}>
        {buttons.map(button => {
          let onClick
          if (button.async_action) {
            onClick = () => this._onClick(button.async_action)
          }
          return (
            <HeaderButton
              key={button.id}
              onClick={onClick}
              icon={button.icon}
              fa={button.fa}
              title={button.title}
              name={button.action}
              href={button.action}
              method={button.method}
              authToken={authToken}
            />
          )
        })}
        {menuItems.length > 0 ? (
          <Dropdown
            mods="stick-right"
            toggle={t('resource_action_more_actions')}
            toggleProps={{ className: 'button' }}>
            <Menu className="ui-drop-menu">
              {menuItems.map(button => {
                let href, onClick
                if (button.async_action) {
                  onClick = () => this._onClick(button.async_action)
                } else if (button.method === 'get') {
                  href = button.action
                } else {
                  throw new Error(
                    'In dropdown, a button must be either async or method "get", ' +
                      'but the dropdown does not support a form with "put/patch".'
                  )
                }

                return (
                  <MenuItem
                    key={button.id}
                    onClick={onClick}
                    href={href}
                    onMouseEnter={null}
                    onMouseLeave={null}
                    target={button.target}>
                    <Icon
                      i={button.icon}
                      mods="ui-drop-icon"
                      style={{
                        position: 'static',
                        display: 'inline-block',
                        minWidth: '20px',
                        marginLeft: '5px'
                      }}
                    />
                    <span style={{ display: 'inline', marginLeft: '5px' }}>{button.title}</span>
                  </MenuItem>
                )
              })}
            </Menu>
          </Dropdown>
        ) : undefined}
      </PageContentHeader>
    )
  }
}

export default MediaEntryHeader
module.exports = MediaEntryHeader
