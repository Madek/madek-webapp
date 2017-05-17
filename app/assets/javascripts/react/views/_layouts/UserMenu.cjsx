# The user menu, in app header on the right side

React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')
Icon = require('../../ui-components/Icon.cjsx')
Dropdown = require('../../ui-components/Dropdown.cjsx')
MenuItem = Dropdown.MenuItem
RailsForm = require('../../lib/forms/rails-form.cjsx')

module.exports = React.createClass
  displayName: 'App.UserMenu'
  propTypes:({
    user_name: React.PropTypes.string.isRequired
    my: React.PropTypes.shape({
      drafts_url: React.PropTypes.string.isRequired,
      entries_url: React.PropTypes.string.isRequired,
      sets_url: React.PropTypes.string.isRequired,
      favorite_entries_url: React.PropTypes.string.isRequired,
      favorite_sets_url: React.PropTypes.string.isRequired,
      groups: React.PropTypes.string.isRequired
    }).isRequired,
    admin: React.PropTypes.shape({ # only set if user is admin
      url: React.PropTypes.string.isRequired
      admin_mode_toggle: React.PropTypes.shape({ # NOT implemented
        url: React.PropTypes.string.isRequired
        method: React.PropTypes.string.isRequired
      })
    }),
    sign_out_action: React.PropTypes.shape({
      url: React.PropTypes.string.isRequired,
      method: React.PropTypes.string.isRequired
    }).isRequired,

    authToken: React.PropTypes.string.isRequired
  })

  render: ({props, state} = this)->
    myContentItems = [
      {
        title: t('sitemap_my_unpublished'), icon: 'cloud',
        url: props.my.drafts_url
      },
      {
        title: t('sitemap_my_clipboard'), icon: 'set',
        url: props.my.clipboard_url
      },
      {
        title: t('user_menu_my_content_media_entries'), icon: 'user',
        url: props.my.entries_url
      },
      {
        title: t('user_menu_my_content_collections'), icon: 'user',
        url: props.my.sets_url
      },
      {
        title: t('user_menu_my_favorite_media_entries'), icon: 'star',
        url: props.my.favorite_entries_url
      },
      {
        title: t('user_menu_my_favorite_collections'), icon: 'star',
        url: props.my.favorite_sets_url
      },
      {
        title: t('user_menu_my_groups'), icon: 'privacy-group',
        url: props.my.groups
      }
    ]

    <Dropdown mods='stick-right'
      toggle={props.user_name}>

      <Dropdown.Menu className='ui-drop-menu'>

        <MenuItem href='/my/upload' className='strong ui-drop-item'>
          <Icon i='upload' mods='ui-drop-icon'/>
          {' ' + t('user_menu_upload')}
        </MenuItem>

        <MenuItem className='separator'/>

        {myContentItems.map (item, index)->
          <MenuItem  href={item.url} key={'key_' + index} className='ui-drop-item'>
            <Icon i={item.icon} mods='mid ui-drop-icon'/>
            {' ' + item.title}
          </MenuItem>
        }

        <MenuItem className='separator'/>

        {# <li className='ui-drop-item'>}
        {#   <a data-method='PUT'}
        {#     href='/users/ebd3a542-2854-4596-b90d-fee281f7c3c3/contrast_mode?contrast_mode=true'>}
        {#     <Icon i='contrast ui-drop-icon mid'/> Kontrast-Modus einschalten</a>}
        {# </li>}

        {# <li className='separator'/>}

        {f.present(props.admin) &&
          <MenuItem href={props.admin.url} className='ui-drop-item'>
            <Icon i='cog ui-drop-icon mid'/>
            {' ' + t('user_menu_admin_ui')}
          </MenuItem>
        }

        {f.present(props.admin) && props.admin.admin_mode_toggle &&
          <MenuItemButton
            name='admin-mode-toggle'
            icon='admin'
            title={props.admin.admin_mode_toggle.title}
            action={props.admin.admin_mode_toggle.url}
            method='POST'
            authToken={props.authToken}
          />
        }

        {f.present(props.admin) && <MenuItem className='separator'/>}

        <MenuItemButton
          name='sign-out'
          icon='power-off'
          title={t('user_menu_logout_btn')}
          action={props.sign_out_action.url}
          method={props.sign_out_action.method}
          authToken={props.authToken}
        />

      </Dropdown.Menu>

    </Dropdown>


MenuItemButton = ({name, action, method, icon, title, authToken})->
  # NOTE: needed style fixes for putting form in menu
  styleFix = {width: '100%', textAlign: 'left', paddingLeft: '7px'}

  <li className='ui-drop-item'>
    <RailsForm
      name='sign-out'
      action={action}
      method={method}
      authToken={authToken}>
      <button className='strong' style={styleFix}>
        <Icon i={icon} mods='ui-drop-icon' />
        {' ' + title}</button>
    </RailsForm>
  </li>
