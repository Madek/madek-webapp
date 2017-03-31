import React from 'react'
import str from '../../../lib/string-translation.js'
const t = str('de')
import Tab from 'react-bootstrap/lib/Tab'
import Nav from 'react-bootstrap/lib/Nav'
import NavItem from 'react-bootstrap/lib/NavItem'
import RailsForm from '../../lib/forms/rails-form.cjsx'

class LoginMenu extends React.Component {
  render ({ authToken, ...restProps } = this.props) {
    // NOTE: can't use Tabs-Component directly because of style issues
    return (
      <div {...restProps}>
        <Tab.Container
          defaultActiveKey='zhdk'
          id='login_menu'
          animation={false}
        >
          <div>
            <Nav className='ui-tabs ui-container'>
              <NavItem eventKey='zhdk' className='ui-tabs-item left'>
                {t('login_box_external')}
              </NavItem>
              <NavItem eventKey='system' className='ui-tabs-item right'>
                {t('login_box_internal')}
              </NavItem>
            </Nav>
            <Tab.Content animation={false} className='ui-tab-content'>
              <Tab.Pane eventKey='zhdk'>
                <div className='form-body'>
                  <div className='ui-form-group rowed'>
                    <p className='mbm'>
                      {t('login_box_hint_first_line')}
                      <br />
                      {t('login_box_hint_second_line')}
                    </p>
                    <a
                      className='primary-button block large'
                      href='/login'
                      id='zhdk-login-link'
                    >
                      {t('login_box_login_btn')}
                    </a>
                  </div>
                </div>
              </Tab.Pane>
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
                      <button
                        className='primary-button block large'
                        type='submit'
                      >
                        {t('login_box_login_btn')}
                      </button>
                    </div>
                  </div>
                </RailsForm>
              </Tab.Pane>
            </Tab.Content>
          </div>
        </Tab.Container>
      </div>
    )
  }
}

export default LoginMenu
