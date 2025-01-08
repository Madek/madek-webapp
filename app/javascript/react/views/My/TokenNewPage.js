import React from 'react'
import f from 'lodash'
import ui from '../../lib/ui.js'
import UI from '../../ui-components/index.js'
import RailsForm from '../../lib/forms/rails-form.cjsx'
const t = ui.t

class TokenNewPage extends React.Component {
  render(props = this.props) {
    const action = f.get(props, 'get.actions.create')
    if (!action) return false

    const descriptionTxt = f.get(props, 'get.given_props.description') || ''
    const callbackUrl = f.get(props, 'get.given_props.callback_url')

    const textAreaStyle = {
      minHeight: 'initial',
      resize: 'vertical'
    }

    return (
      <div
        className="by-center"
        style={{ marginLeft: 'auto', marginRight: 'auto' }}
      >
        <div
          className="ui-container bright bordered rounded mal phm pbm"
          style={{ display: 'inline-block', minWidth: '420px' }}
        >
          <RailsForm
            name="api_token"
            method={action.method}
            action={action.url}
            authToken={props.authToken}
          >
            <div className="ui-form-group rowed prn pbs">
              <h3 className="title-l">{t('api_tokens_create_title')}</h3>
            </div>
            {callbackUrl && (
              <div className="ui-alert confirmation normal mbs">
                {t('api_tokens_callback_description')}
                <br />
                <samp className="f5 code">URL: {callbackUrl}</samp>
                <input type="hidden" name="callback_url" value={callbackUrl} />
              </div>
            )}
            <div className="ui-form-group rowed pan ">
              <label className="form-label">
                {t('api_tokens_create_description')}
                <textarea
                  className="form-item block"
                  style={textAreaStyle}
                  name={'api_token[description]'}
                  defaultValue={descriptionTxt}
                  rows={Math.max(3, descriptionTxt.split('\n').length + 1)}
                />
              </label>
            </div>
            <label className="ui-form-group rowed pan mbs">
              <div className="form-label">
                {t('api_tokens_head_permissions')}
              </div>
              <div className="form-item">
                <label className="col1of2">
                  <input type="checkbox" defaultChecked={true} disabled />
                  {t('api_tokens_list_scope_read')}
                </label>
                <label className="col1of2">
                  <input
                    type="checkbox"
                    name={'api_token[scope_write]'}
                    defaultChecked={false}
                  />
                  {t('api_tokens_list_scope_write')}
                </label>
              </div>
            </label>
            <div className="ui-actions mtm">
              <UI.Button type="submit" className="primary-button">
                {t('api_tokens_create_submit')}
              </UI.Button>
              <UI.Button href={action.url} className="button">
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
