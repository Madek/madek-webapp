React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../../../lib/string-translation.js')('de')

module.exports = React.createClass
  displayName: 'LoginDialog'

  getInitialState: () -> { active: false }

  render: ({authToken} = @props) ->

    <div className="ui-home-claim ui-container">
      <div className="col2of3">
        <div className="pitch-claim">
          <h1 className="title-xxl">
            {t('login_box_title')}
          </h1>
          <div className="ptm">
            <p>
              <strong>{t('login_box_cite')}</strong>
              <br />
              {t('login_box_author')}
            </p>
          </div>
        </div>
      </div>
      <div className="col1of3">
        <div className="pitch-login">
          <ul className="ui-tabs ui-container">
            <li className="ui-tabs-item left active">
              <a data-toggle="tab" href="#zhdk-user" id="zhdk-user-login-tab">
                {t('login_box_external')}
              </a>
            </li>
            <li className="ui-tabs-item right">
              <a data-toggle="tab" href="#database-user" id="database-user-login-tab">
                {t('login_box_internal')}
              </a>
            </li>
          </ul>
          <div className="pitch-login-tab tab-content">
            <div className="tab-pane active" id="zhdk-user">
              <form>
                <div className="form-body">
                  <div className="ui-form-group rowed">
                    <p className="mbm">
                      {t('login_box_hint_first_line')}
                      <br />
                      {t('login_box_hint_second_line')}
                    </p>
                    <a className="primary-button block large" href="/login" id="zhdk-login-link">
                      {t('login_box_login_btn')}
                    </a>
                  </div>
                </div>
              </form>
            </div>

            <div className="tab-pane" id="database-user">
              <form accept-charset="UTF-8" action="/session/sign_in" method="post">
                <div style={{ display: 'none' }}>
                  <input name="utf8" type="hidden" value="✓" />
                  <input name="authenticity_token" type="hidden" value="K/8D7uhCZZHrZlWQbgEdzNlLRm8jVEMJ8HYvKPIEWuM=" />
                </div>
                <div className="form-body">
                  <div className="ui-form-group rowed compact">
                    <input autofocus="false" className="block large" name="login"
                      placeholder={t('login_box_username')} type="text" />
                  </div>
                  <div className="ui-form-group rowed compact">
                    <input className="block large" name="password" placeholder={t('login_box_password')} type="password" />
                  </div>
                  <div className="ui-form-group rowed compact by-left">
                    <div className="form-item">
                      <input type="checkbox" name="remember_me" id="remember_me"
                        value="remember me" defaultChecked="checked" />
                      <label for="remember_me">{t('login_box_rememberme')}</label>
                    </div>
                  </div>
                  <div className="ui-form-group rowed compact">
                    <button className="primary-button block large" type="submit">
                      {t('login_box_login_btn')}
                    </button>
                  </div>
                </div>
              </form>

            </div>
          </div>
        </div>
      </div>
    </div>
