# The user menu, in app header on the right side

React = require('react')
f = require('active-lodash')
ui = require('../../lib/ui.coffee')
t = ui.t('de')
Icon = require('../../ui-components/Icon.cjsx')
Dropdown = require('../../ui-components/Dropdown.cjsx')
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
      # super_action: React.PropTypes.shape({ # NOT implemented
      #   url: React.PropTypes.string.isRequired
      #   method: React.PropTypes.string.isRequired
      # })
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
        title: t('sitemap_my_content_media_entries'), icon: 'user',
        url: props.my.entries_url
      },
      {
        title: t('sitemap_my_content_collections'), icon: 'user',
        url: props.my.sets_url
      },
      {
        title: t('sitemap_my_favorite_media_entries'), icon: 'star',
        url: props.my.favorite_entries_url
      },
      {
        title: t('sitemap_my_favorite_collections'), icon: 'star',
        url: props.my.favorite_sets_url
      },
      {
        title: t('sitemap_my_groups'), icon: 'privacy-group',
        url: props.my.groups
      }
    ]

    <Dropdown mods='stick-right'
      toggle={props.user_name}>

      <ul className="dropdown-menu ui-drop-menu" role="menu">

        <li className="ui-drop-item">
          <a className="strong" href="/my/upload">
            <Icon i="upload" mods="ui-drop-icon"/>
            {' ' + t('user_menu_upload')}
          </a>
        </li>

        <li className="separator"/>

        {myContentItems.map (item)->
          <li className="ui-drop-item">
            <a href={item.url}>
              <Icon i={item.icon} mods="mid ui-drop-icon"/>
              {' ' + item.title}</a>
          </li>
        }

        <li className="separator"/>

        {# <li className="ui-drop-item">}
        {#   <a data-method="PUT"}
        {#     href="/users/ebd3a542-2854-4596-b90d-fee281f7c3c3/contrast_mode?contrast_mode=true">}
        {#     <Icon i="contrast ui-drop-icon mid"/> Kontrast-Modus einschalten</a>}
        {# </li>}

        {# <li className="separator"/>}

        {if f.present(props.admin)
          <li className="ui-drop-item">
            <a href={props.admin.url}>
              <Icon i="cog ui-drop-icon mid"/>
              {' ' + t('user_menu_admin_ui')}</a>
          </li>

          {# <li className="ui-drop-item">}
          {#   <a className="" data-method="POST"}
          {#     href="/app_admin/enter_uberadmin" id="switch-to-uberadmin">}
          {#     <Icon i="admin ui-drop-icon mid"/>}
          {#     {' ' + 'In Admin-Modus wechseln'}</a>}}
          {# </li>}
        }

        <li className="separator"/>

        <li className="ui-drop-item">
          {# FIXME: style fixes…}
          {styleFix = {width: '100%', textAlign: 'left', paddingLeft: '7px'}
          <RailsForm name='sign-out'
            action={props.sign_out_action.url}
            method={props.sign_out_action.method}
            authToken={props.authToken}>
            <button className="strong" style={styleFix}>
              <Icon i="power-off" mods="ui-drop-icon" />
              {' ' + t('user_menu_logout_btn')}</button>
          </RailsForm>}
        </li>
      </ul>

    </Dropdown>