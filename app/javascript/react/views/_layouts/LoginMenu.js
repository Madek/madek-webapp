import React from 'react'
import cx from 'classnames'
import t from '../../../lib/i18n-translate.js'
import Tab from 'react-bootstrap/lib/Tab'

class LoginMenu extends React.Component {
  constructor(props) {
    super(props)
    this.state = { loginName: '' }
  }

  render({ authToken, for_url, returnTo, lang, className, ...restProps } = this.props) {
    // (`no-unused-vars` because `authToken` and `for_url` are passed to props due to force majeure,
    // but are not needed here and otherwise would go to the DOM via restProps)
    return (
      <div className={cx(className, 'pitch-login')} {...restProps}>
        <div id="login_menu">
          <Tab.Content animation={false} className="ui-tab-content">
            <form method="GET" action="/auth/sign-in/auth-systems/">
              <div className="form-body">
                <div className="ui-form-group rowed compact">
                  <label className="form-label">{t('login_box_title')}</label>
                  <input
                    autoFocus="false"
                    className="block large"
                    name="email-or-login"
                    placeholder={t('login_box_email_or_login')}
                    type="text"
                    value={this.state.loginName}
                    onChange={e => this.setState({ loginName: e.target.value })}
                  />
                </div>
                <div className="ui-form-group rowed compact">
                  <input type="hidden" name="return-to" defaultValue={returnTo} />
                  <input type="hidden" name="lang" defaultValue={lang} />
                  <button className="primary-button block large" type="submit">
                    {t('login_box_login_btn')}
                  </button>
                </div>
              </div>
            </form>
          </Tab.Content>
        </div>
      </div>
    )
  }
}

export default LoginMenu
