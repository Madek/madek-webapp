import React from 'react'

import ui from '../../lib/ui.coffee'
const t = ui.t('de')
import Icon from '../../ui-components/Icon.cjsx'
import UserMenu from '../_layouts/UserMenu.cjsx'

const AppHeader = ({brand, menu, user, userMenu, loginLink, show_user_menu, authToken}) => {
  const LoginButton = ({href}) =>
    <a className='tertiary-button' href={href}>
      <i className='icon icon-user' />{' '}
      {t('user_menu_login_btn')}
    </a>

  const Brand = ({name, logo, provider, href}) =>
    <a href={href}>
      {!!logo &&
        // a11y: logo is just the visual representation of the
        // (already present) 'name', so `alt` should be empty string:
        <img className='ui-header-logo' src={logo} alt={''} />
      }
      <h1 className='ui-header-brand-name'>{provider}</h1>
      <h2 className='ui-header-instance-name'>{name}</h2>
    </a>

  const MainMenu = ({menu}) =>
    <ul className='ui-tabs primary large' id='main_menu'>
      {menu.map(([key, tab]) => {
        if (!tab) return null
        const {href, text, icon, active} = tab
        return (
          <li key={key} className={ui.cx('ui-tabs-item', {'active': active})}>
            <a href={href} id={`main_menu-${key}`}>
              {!!icon && <Icon i={icon} mods='bright' />}{!!icon && ' '}
              {text}
            </a>
          </li>
        ) }
      )}
    </ul>

  return <header className='ui-header ui-container inverted'>
    {!!brand &&
      <div className='ui-header-brand'><Brand {...brand} /></div>}
    {!!menu &&
      <div className='ui-header-menu'><MainMenu menu={menu} /></div>}
    {!!show_user_menu &&
      <div className='ui-header-user'>
        {userMenu
          ? <UserMenu {...userMenu} authToken={authToken}/>
          : <LoginButton href={loginLink} />}
      </div>}
  </header>
}

export default AppHeader
