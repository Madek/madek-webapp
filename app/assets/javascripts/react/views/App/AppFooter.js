import React from 'react'
import isEmpty from 'lodash/isEmpty'
const {isArray} = Array

const MadekLogoType = () =>
  <b style={{
    fontFamily: 'Open Sans, sans-serif',
    fontWeight: 600,
    fontSize: '16px'
  }}>
    Madek
  </b>

const footerVersion = ({version, title, name, description, info_url}) =>
  <span className='version' title={title}>
    {version}
    {!!name && ' '}
    {!!name && <a href={info_url} title={description}>{name}</a>}
  </span>

const AppFooter = ({provider, version, menu}) =>
  <footer className='app-footer ui-footer ui-container inverted'>
    {isArray(menu) && !isEmpty(menu) &&
      <ul className='ui-footer-menu'>
        {menu.map((item, i) => {
          const text = Object.keys(item)[0]
          const href = item[text]
          return <li key={i + href}><a href={href}>{text}</a></li>
        })}
      </ul>
    }

    {(provider || !!version) &&
      <div className='ui-footer-copy'>
        <MadekLogoType />{' '}
        {footerVersion(version)}
        {!!provider && ' - '}
        {provider}
      </div>
    }
  </footer>

export default AppFooter
