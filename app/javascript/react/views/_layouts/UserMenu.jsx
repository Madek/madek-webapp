// The user menu, in app header on the right side

import React from 'react'
import PropTypes from 'prop-types'
import { t } from '../../lib/ui.js'
import Icon from '../../ui-components/Icon.jsx'
import Dropdown, { MenuItem } from '../../ui-components/Dropdown.jsx'
import RailsForm from '../../lib/forms/rails-form.jsx'
import { present } from '../../../lib/utils.js'

class UserMenu extends React.Component {
  static propTypes = {
    user_name: PropTypes.string.isRequired,
    my: PropTypes.shape({
      drafts_url: PropTypes.string.isRequired,
      entries_url: PropTypes.string.isRequired,
      sets_url: PropTypes.string.isRequired,
      favorite_entries_url: PropTypes.string.isRequired,
      favorite_sets_url: PropTypes.string.isRequired,
      groups: PropTypes.string.isRequired
    }).isRequired,
    admin: PropTypes.shape({
      // only set if user is admin
      url: PropTypes.string.isRequired,
      admin_mode_toggle: PropTypes.shape({
        // NOT implemented
        url: PropTypes.string.isRequired,
        method: PropTypes.string.isRequired
      })
    }),
    sign_out_action: PropTypes.shape({
      url: PropTypes.string.isRequired,
      method: PropTypes.string.isRequired
    }).isRequired,

    authToken: PropTypes.string.isRequired
  }

  render() {
    const { props } = this
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
          {present(props.admin) && (
            <MenuItem href={props.admin.url} className="ui-drop-item">
              <Icon i="cog ui-drop-icon mid" />
              {` ${t('user_menu_admin_ui')}`}
            </MenuItem>
          )}
          {present(props.admin) && props.admin.admin_mode_toggle && (
            <MenuItemButton
              name="admin-mode-toggle"
              icon="admin"
              title={props.admin.admin_mode_toggle.title}
              action={props.admin.admin_mode_toggle.url}
              method="POST"
              authToken={props.authToken}
            />
          )}
          {present(props.admin) && <MenuItem className="separator" />}
          {props.sign_out_action.mode === 'auth-app' && (
            <AuthAppSignoutButton {...props.sign_out_action} />
          )}
          {props.sign_out_action.mode === 'webapp' && (
            <WebappSignoutButton {...props.sign_out_action} authToken={props.authToken} />
          )}
        </Dropdown.Menu>
      </Dropdown>
    )
  }
}

// Sign out via auth
const AuthAppSignoutButton = ({ url, method, auth_anti_csrf_param, auth_anti_csrf_token }) => (
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
const WebappSignoutButton = ({ url, method, authToken }) => (
  <MenuItemButton
    name="sign-out"
    icon="power-off"
    title={t('user_menu_logout_btn') + ' (via Webapp!)'}
    action={url}
    method={method}
    authToken={authToken}
  />
)

const MenuItemButton = ({ action, method, icon, title, authToken }) => {
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

export default UserMenu
module.exports = UserMenu
