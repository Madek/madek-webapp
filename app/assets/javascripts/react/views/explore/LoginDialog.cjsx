React = require('react')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')
Tab = require('react-bootstrap/lib/Tab')
Nav = require('react-bootstrap/lib/Nav')
NavItem = require('react-bootstrap/lib/NavItem')
RailsForm = require('../../lib/forms/rails-form.cjsx')

module.exports = React.createClass
  displayName: 'LoginDialog'

  getInitialState: () -> { active: false }

  render: ({welcomeMessage, authToken} = @props) ->

    <div className='ui-home-claim ui-container'>
      <div className='col2of3'>
        <div className='pitch-claim'>
          <h1 className='title-xxl'>
            {welcomeMessage.title}
          </h1>
          <div className='ptm' dangerouslySetInnerHTML={welcomeMessage.text} />
        </div>
      </div>
      <div className='col1of3'>
        <div className='pitch-login'>

          {# NOTE: can't use Tabs-Component directly because of style issues }
          <Tab.Container defaultActiveKey='zhdk' id='login_menu' animation={false}>
            <div>
              <Nav className='ui-tabs ui-container' >
                <NavItem eventKey="zhdk" className="ui-tabs-item left">
                  {t('login_box_external')}
                </NavItem>
                <NavItem eventKey="system"  className="ui-tabs-item right">
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
                      <a className='primary-button block large' href='/login' id='zhdk-login-link'>
                        {t('login_box_login_btn')}
                      </a>
                    </div>
                  </div>
                </Tab.Pane>

                <Tab.Pane eventKey='system'>
                  <RailsForm action='/session/sign_in' authToken={authToken}>
                    <div className='form-body'>
                      <div className='ui-form-group rowed compact'>
                        <input autofocus='false' className='block large' name='login'
                          placeholder={t('login_box_username')} type='text' />
                      </div>
                      <div className='ui-form-group rowed compact'>
                        <input className='block large' name='password'
                          placeholder={t('login_box_password')} type='password' />
                      </div>
                      <div className='ui-form-group rowed compact by-left'>
                        <div className='form-item'>
                          <input type='checkbox' name='remember_me' id='remember_me'
                            value='remember me' defaultChecked='checked' />
                          <label for='remember_me'>{t('login_box_rememberme')}</label>
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

              </Tab.Content>

            </div>
          </Tab.Container>

        </div>
      </div>
    </div>
