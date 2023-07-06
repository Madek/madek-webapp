import React from 'react'
import cx from 'classnames'
import f from 'lodash'
import t from '../../../lib/i18n-translate.js'
import Tab from 'react-bootstrap/lib/Tab'
import Nav from 'react-bootstrap/lib/Nav'
import NavItem from 'react-bootstrap/lib/NavItem'
import RailsForm from '../../lib/forms/rails-form.cjsx'

class LoginMenu extends React.Component {
  render({ authToken, loginProviders, className, ...restProps } = this.props) {
    if (!loginProviders) {
      return false
    }

    if (loginProviders.length === 1 && loginProviders[0].id === 'system') {
      return (
        <div id="login_menu" className="ui-container mts pam bright bordered rounded">
          {systemLogin({ authToken, ...loginProviders[0] })}
        </div>
      )
    }

    // NOTE: can't use Tabs-Component directly because of style issues
    return (
      <div className={cx(className, 'pitch-login')} {...restProps}>
        <Tab.Container defaultActiveKey={loginProviders[0].id} id="login_menu">
          <div>
            <Nav className="ui-tabs ui-container">
              {loginProviders.map(({ id, title }) => (
                <NavItem className="ui-tabs-item left" eventKey={id} key={id}>
                  {title}
                </NavItem>
              ))}
            </Nav>
            <Tab.Content animation={false} className="ui-tab-content">
              {loginProviders.map(({ id, ...loginProps }) => {
                if (id === 'system') {
                  return (
                    <Tab.Pane eventKey="system" key={id}>
                      {systemLogin({ authToken, ...loginProps })}
                    </Tab.Pane>
                  )
                } else {
                  return (
                    <Tab.Pane eventKey={id} key={id}>
                      {providerLogin({ ...loginProps })}
                    </Tab.Pane>
                  )
                }
              })}
            </Tab.Content>
          </div>
        </Tab.Container>
      </div>
    )
  }
}

export default LoginMenu

const providerLogin = ({ description, href, buttonTxt }) => (
  <div className="form-body">
    <div className="ui-form-group rowed">
      <p className="mbm">
        {description.split('\n').map((line, index) => (
          <span key={index}>
            {line}
            <br />
          </span>
        ))}
      </p>
      <a className="primary-button block large" href={href}>
        {buttonTxt || t('login_box_login_btn')}
      </a>
    </div>
  </div>
)

const systemLogin = ({ url, authToken }) => {
  if (f.isEmpty(url)) throw new Error('Missing URL!')
  return (
    <RailsForm action={url} authToken={authToken} name="login_form">
      <div className="form-body">
        <div className="ui-form-group rowed compact">
          <input
            autoFocus="false"
            className="block large"
            name="login"
            placeholder={t('login_box_username')}
            type="text"
          />
        </div>
        <div className="ui-form-group rowed compact">
          <input
            className="block large"
            name="password"
            placeholder={t('login_box_password')}
            type="password"
          />
        </div>
        <div className="ui-form-group rowed compact by-left">
          <div className="form-item">
            <input
              type="checkbox"
              name="remember_me"
              id="remember_me"
              value="remember me"
              defaultChecked="checked"
            />
            <label htmlFor="remember_me">{t('login_box_rememberme')}</label>
          </div>
        </div>
        <div className="ui-form-group rowed compact">
          <button className="primary-button block large" type="submit">
            {t('login_box_login_btn')}
          </button>
        </div>
      </div>
    </RailsForm>
  )
}
