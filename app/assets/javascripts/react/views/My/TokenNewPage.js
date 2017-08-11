import React from 'react'
import f from 'lodash'
import ui from '../../lib/ui.coffee'
import UI from '../../ui-components/index.coffee'
import RailsForm from '../../lib/forms/rails-form.cjsx'
const t = ui.t

class TokenNewPage extends React.Component {
  render (props = this.props) {
    const action = f.get(props, 'get.actions.create')
    if (!action) return false

    const descriptionTxt = ''
    const textAreaStyle = {
      minHeight: 'initial',
      resize: 'vertical',
      height: '2.4em'
    }

    return (
      <div
        className='by-center'
        style={{ marginLeft: 'auto', marginRight: 'auto' }}
      >
        <div
          className='ui-container bright bordered rounded mal phl pbs'
          style={{ display: 'inline-block' }}
        >
          <RailsForm
            method={action.method}
            action={action.url}
            authToken={props.authToken}
          >
            <div className='ui-form-group rowed prn'>
              <h3 className='title-l'>
                {t('api_tokens_create_title')}
              </h3>
            </div>
            <div className='ui-form-group rowed pan mbs'>
              <label className='form-label'>
                {t('api_tokens_create_description')}
                <textarea
                  className='form-item block'
                  style={textAreaStyle}
                  name={'api_token[description]'}
                  defaultValue={descriptionTxt}
                  rows={descriptionTxt.split('\n').length}
                />
              </label>
            </div>
            <div className='ui-actions mtm'>
              <UI.Button type='submit' className='primary-button'>
                {t('api_tokens_create_submit')}
              </UI.Button>
              <UI.Button href={action.url} className='button'>
                {t('api_tokens_create_cancel')}
              </UI.Button>
            </div>
          </RailsForm>
        </div>
      </div>
    )
  }
}

module.exports = TokenNewPage
