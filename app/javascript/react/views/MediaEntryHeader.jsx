/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const HeaderButton = require('./HeaderButton.cjsx')
const PageContentHeader = require('./PageContentHeader.cjsx')
const f = require('active-lodash')
const SelectCollection = require('./Collection/SelectCollection.cjsx')
const AsyncModal = require('./Collection/AsyncModal.cjsx')
const Dropdown = require('../ui-components/Dropdown.cjsx')
const { Menu } = Dropdown
const { MenuItem } = Dropdown
const Icon = require('../ui-components/Icon.cjsx')
const Link = require('../ui-components/Link.cjsx')
const t = require('../../lib/i18n-translate.js')

module.exports = React.createClass({
  displayName: 'MediaEntryHeader',

  getInitialState() {
    return {
      active: this.props.isClient
    }
  },

  _onClick(asyncAction) {
    if (this.props.onClick) {
      return this.props.onClick(asyncAction)
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    const icon = get.type === 'Collection' ? 'set' : 'media-entry'

    const buttons = f.compact(
      f.map(get.button_actions, button_id => f.find(get.buttons, { id: button_id }))
    )

    const menuItems = f.compact(
      f.map(get.dropdown_actions, button_id => f.find(get.buttons, { id: button_id }))
    )

    const banner = f.any(get.new_version_entries) ? (
      <div className="ui-alert warning ui-container inverted paragraph-l mbm">
        {t('media_entry_notice_new_versions')}
        <ul>
          {f.map(get.new_version_entries, i => {
            let left
            const me = i.entry
            const desc =
              (left = f.present(i.description)) != null ? left : i.description + { ', ': '' }
            return (
              <li>
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
    ) : (
      undefined
    )

    return (
      <PageContentHeader
        icon={icon}
        title={get.title}
        workflow={get.workflow}
        banner={banner}
        sectionLabels={get.section_labels}>
        {f.map(buttons, button => {
          let onClick
          if (button.async_action) {
            onClick = event => this._onClick(button.async_action)
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
        {!f.isEmpty(menuItems) ? (
          <Dropdown
            mods="stick-right"
            toggle={t('resource_action_more_actions')}
            toggleProps={{ className: 'button' }}>
            <Menu className="ui-drop-menu">
              {f.map(menuItems, button => {
                let href, onClick
                if (button.async_action) {
                  onClick = event => this._onClick(button.async_action)
                } else if (button.method === 'get') {
                  href = button.action
                } else {
                  throw new Error(
                    'In dropdown, a button must be either async or method "get", ',
                    +'but the dropdown does not support a form with "put/patch".'
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
        ) : (
          undefined
        )}
      </PageContentHeader>
    )
  }
})
