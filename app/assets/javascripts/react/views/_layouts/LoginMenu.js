import React from 'react'
import cx from 'classnames'
import str from '../../../lib/string-translation.js'
const t = str('de')
import Tab from 'react-bootstrap/lib/Tab'
import Nav from 'react-bootstrap/lib/Nav'
import NavItem from 'react-bootstrap/lib/NavItem'
import RailsForm from '../../lib/forms/rails-form.cjsx'

class LoginMenu extends React.Component {
  render ({ authToken, loginProviders, className, ...restProps } = this.props) {
    // NOTE: can't use Tabs-Component directly because of style issues
    return (
      <div className={cx(className, 'pitch-login')} {...restProps}>
        <Tab.Container
          defaultActiveKey={loginProviders[0].id}
          id='login_menu'
          animation={false}
        >
          <div>
            <Nav className='ui-tabs ui-container'>
              {loginProviders.map(({ id, title }) => (
                <NavItem className='ui-tabs-item left' eventKey={id} key={id}>
                  {title}
                </NavItem>
                ))}
            </Nav>
            <Tab.Content animation={false} className='ui-tab-content'>
              {loginProviders.map(
                  ({ id, title, href, description, buttonTxt }) =>
                    id === 'system'
                      ? systemLoginPane({ title, authToken })
                      : <Tab.Pane eventKey={id} key={id}>
                        <div className='form-body'>
                          <div className='ui-form-group rowed'>
                            <p className='mbm'>
                              {
                                description
                                  .split('\n')
                                  .map(line => <span>{line}<br /></span>)
                              }
                            </p>
                            <a
                              className='primary-button block large'
                              href={href}
                            >
                              {buttonTxt || t('login_box_login_btn')}
                            </a>
                          </div>
                        </div>
                      </Tab.Pane>
                )}
            </Tab.Content>
          </div>
        </Tab.Container>
      </div>
    )
  }
}

export default LoginMenu

const systemLoginPane = ({ title, authToken }) => (
  <Tab.Pane eventKey='system'>
    <RailsForm action='/session/sign_in' authToken={authToken}>
      <div className='form-body'>
        <div className='ui-form-group rowed compact'>
          <input
            autofocus='false'
            className='block large'
            name='login'
            placeholder={t('login_box_username')}
            type='text'
          />
        </div>
        <div className='ui-form-group rowed compact'>
          <input
            className='block large'
            name='password'
            placeholder={t('login_box_password')}
            type='password'
          />
        </div>
        <div className='ui-form-group rowed compact by-left'>
          <div className='form-item'>
            <input
              type='checkbox'
              name='remember_me'
              id='remember_me'
              value='remember me'
              defaultChecked='checked'
            />
            <label for='remember_me'>
              {t('login_box_rememberme')}
            </label>
          </div>
        </div>
        <div className='ui-form-group rowed compact'>
          <button className='primary-button block large' type='submit'>
            {t('login_box_login_btn')}
          </button>
        </div>
      </div>
    </RailsForm>
  </Tab.Pane>
)
