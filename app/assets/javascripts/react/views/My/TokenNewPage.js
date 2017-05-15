import React from 'react'
import f from 'lodash'
import Moment from 'moment'
Moment.locale('de')

const UI = require('../../ui-components/index.coffee')
const RailsForm = require('../../lib/forms/rails-form.cjsx')

class TokenNewPage extends React.Component {
  render (props = this.props) {
    const action = f.get(props, 'get.actions.create')
    if (!action) return false

    // $Username - do you want to add a new token?
    return (
      <div
        className='ui-container bright bordered rounded mal phm pbm'
        style={{ marginLeft: 'auto', marginRight: 'auto' }}
      >
        <RailsForm
          method={action.method}
          action={action.url}
          authToken={props.authToken}
        >
          <div className='ui-form-group rowed'>
            <h3 className='title-l'>Neuen Token hinzufügen</h3>
          </div>
          <div className='ui-form-group rowed'>
            <label className='form-label'>
              {'Beschreibung'}
              <input
                type={'text'}
                className='form-item'
                style={{ width: '100%' }}
                name={'api_token[description]'}
                defaultValue={''}
                placeholder={''}
              />
            </label>
          </div>
          <div className='ui-actions'>
            <UI.Button type='submit' className='primary-button'>
              Token anlegen
            </UI.Button>
            <UI.Button href='/my/tokens' className='button'>
              Abbrechen
            </UI.Button>
          </div>
        </RailsForm>
      </div>
    )
  }
}

module.exports = TokenNewPage
