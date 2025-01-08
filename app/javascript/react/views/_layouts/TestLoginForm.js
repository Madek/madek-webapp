import React from 'react'
import RailsForm from '../../lib/forms/rails-form.jsx'
import Tab from 'react-bootstrap/lib/Tab'

class TestLoginForm extends React.Component {
  constructor(props) {
    super(props)
  }

  render({ authToken, path, returnTo, emailOrLogin } = this.props) {
    if ((path || '') === '') throw new Error('Missing target path!')
    const postUrl = `${path}?return_to=${encodeURIComponent(returnTo || '')}`

    return (
      <div className="pitch-login">
        <div id="login_menu">
          <Tab.Content animation={false} className="ui-tab-content">
            <RailsForm action={postUrl} authToken={authToken} name="login_form">
              <div className="form-body">
                <div className="ui-form-group rowed compact">
                  <input
                    autoFocus="false"
                    className="block large"
                    name="login"
                    placeholder="Benutzername"
                    type="text"
                    defaultValue={emailOrLogin}
                  />
                </div>
                <div className="ui-form-group rowed compact">
                  <input
                    className="block large"
                    name="password"
                    placeholder="Passwort"
                    type="password"
                  />
                </div>
                <div className="ui-form-group rowed compact">
                  <button className="primary-button block large" type="submit">
                    Anmelden
                  </button>
                </div>
              </div>
            </RailsForm>
          </Tab.Content>
        </div>
      </div>
    )
  }
}

export default TestLoginForm
