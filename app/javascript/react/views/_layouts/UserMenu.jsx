/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// The user menu, in app header on the right side

const React = require('react')
const f = require('active-lodash')
const ui = require('../../lib/ui.js')
const { t } = ui
const Icon = require('../../ui-components/Icon.jsx')
const Dropdown = require('../../ui-components/Dropdown.jsx')
const { MenuItem } = Dropdown
const RailsForm = require('../../lib/forms/rails-form.jsx')

module.exports = React.createClass({
  displayName: 'App.UserMenu',
  propTypes: {
    user_name: React.PropTypes.string.isRequired,
    my: React.PropTypes.shape({
      drafts_url: React.PropTypes.string.isRequired,
      entries_url: React.PropTypes.string.isRequired,
      sets_url: React.PropTypes.string.isRequired,
      favorite_entries_url: React.PropTypes.string.isRequired,
      favorite_sets_url: React.PropTypes.string.isRequired,
      groups: React.PropTypes.string.isRequired
    }).isRequired,
    admin: React.PropTypes.shape({
      // only set if user is admin
      url: React.PropTypes.string.isRequired,
      admin_mode_toggle: React.PropTypes.shape({
        // NOT implemented
        url: React.PropTypes.string.isRequired,
        method: React.PropTypes.string.isRequired
      })
    }),
    sign_out_action: React.PropTypes.shape({
      url: React.PropTypes.string.isRequired,
      method: React.PropTypes.string.isRequired
    }).isRequired,

    authToken: React.PropTypes.string.isRequired
  },

  render(param) {
    if (param == null) {
      param = this
    }
    const { props, state } = param
    const myContentItems = [
      {
        title: t('sitemap_my_unpublished'),
        icon: 'pen',
        url: props.my.drafts_url
      },
      {
        title: t('sitemap_my_clipboard'),
        icon: 'clipboard',
        url: props.my.clipboard_url
      },
      {
        title: t('user_menu_my_content_media_entries'),
        icon: 'media-entry',
        url: props.my.entries_url
      },
      {
        title: t('user_menu_my_content_collections'),
        icon: 'set',
        url: props.my.sets_url
      },
      {
        title: t('user_menu_my_favorite_media_entries'),
        icon: 'star',
        url: props.my.favorite_entries_url
      },
      {
        title: t('user_menu_my_favorite_collections'),
        icon: 'star',
        url: props.my.favorite_sets_url
      },
      {
        title: t('user_menu_my_person'),
        icon: 'user',
        url: props.my.person_url
      },
      {
        title: t('user_menu_my_groups'),
        icon: 'privacy-group',
        url: props.my.groups
      }
    ]

    return (
      <Dropdown mods="stick-right" toggle={props.user_name}>
        <Dropdown.Menu className="ui-drop-menu">
          <MenuItem href={props.import_url} className="strong ui-drop-item">
            <Icon i="upload" mods="ui-drop-icon" />
            {` ${t('user_menu_upload')}`}
          </MenuItem>
          <MenuItem className="separator" />
          {myContentItems.map((item, index) => (
            <MenuItem href={item.url} key={`key_${index}`} className="ui-drop-item">
              <Icon i={item.icon} mods="mid ui-drop-icon" />
              {` ${item.title}`}
            </MenuItem>
          ))}
          <MenuItem className="separator" />
          {f.present(props.admin) && (
            <MenuItem href={props.admin.url} className="ui-drop-item">
              <Icon i="cog ui-drop-icon mid" />
              {` ${t('user_menu_admin_ui')}`}
            </MenuItem>
          )}
          {f.present(props.admin) && props.admin.admin_mode_toggle && (
            <MenuItemButton
              name="admin-mode-toggle"
              icon="admin"
              title={props.admin.admin_mode_toggle.title}
              action={props.admin.admin_mode_toggle.url}
              method="POST"
              authToken={props.authToken}
            />
          )}
          {f.present(props.admin) && <MenuItem className="separator" />}
          {props.sign_out_action.mode === 'auth-app' && (
            <AuthAppSignoutButton {...Object.assign({}, props.sign_out_action)} />
          )}
          {props.sign_out_action.mode === 'webapp' && (
            <WebappSignoutButton
              {...Object.assign({}, props.sign_out_action, { authToken: props.authToken })}
            />
          )}
        </Dropdown.Menu>
      </Dropdown>
    )
  }
})

// Sign out via auth
var AuthAppSignoutButton = ({ url, method, auth_anti_csrf_param, auth_anti_csrf_token }) => (
  <li className="ui-drop-item">
    <form name="sign-out" action={url} method={method}>
      <input type="hidden" name={auth_anti_csrf_param} defaultValue={auth_anti_csrf_token} />
      <button className="strong" style={{ width: '100%', textAlign: 'left', paddingLeft: '7px' }}>
        <Icon i="power-off" mods="ui-drop-icon" />
        {` ${t('user_menu_logout_btn')}`}
      </button>
    </form>
  </li>
)

// Sign out via webapp
var WebappSignoutButton = ({ url, method, authToken }) => (
  <MenuItemButton
    name="sign-out"
    icon="power-off"
    title={t('user_menu_logout_btn') + ' (via Webapp!)'}
    action={url}
    method={method}
    authToken={authToken}
  />
)

var MenuItemButton = function({ name, action, method, icon, title, authToken }) {
  // NOTE: needed style fixes for putting form in menu
  const styleFix = { width: '100%', textAlign: 'left', paddingLeft: '7px' }

  return (
    <li className="ui-drop-item">
      <RailsForm name="sign-out" action={action} method={method} authToken={authToken}>
        <button className="strong" style={styleFix}>
          <Icon i={icon} mods="ui-drop-icon" />
          {` ${title}`}
        </button>
      </RailsForm>
    </li>
  )
}
