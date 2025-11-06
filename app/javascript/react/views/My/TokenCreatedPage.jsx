import React from 'react'
import f from 'lodash'
import { TokenRow } from './Tokens.jsx'
import ui from '../../lib/ui.js'
import UI from '../../ui-components/index.js'
import setUrlParams from '../../../lib/set-params-for-url.js'
const t = ui.t

class TokenCreatedPage extends React.Component {
  render(props = this.props) {
    const { get } = props
    const indexAction = f.get(get, 'actions.index.url')
    const callbackAction = f.get(get, 'actions.callback.url')
    const callbackLink = setUrlParams(callbackAction, {
      madek_api_token: get.secret
    })

    return (
      <div className="by-center" style={{ marginLeft: 'auto', marginRight: 'auto' }}>
        <div
          className="ui-container bright bordered rounded mal phl pbs"
          style={{ display: 'inline-block' }}>
          <h3 className="title-l mas">{t('api_tokens_created_title')}</h3>
          {!callbackAction && (
            <div>
              <div className="ui-alert confirmation">{t('api_tokens_created_notice')}</div>
              <p
                className="ui-container bordered rounded mam pas"
                style={{ display: 'inline-block' }}>
                <samp className="title-m code b">{get.secret}</samp>
              </p>
            </div>
          )}
          {callbackAction && (
            <div>
              <div className="ui-container pal">
                <UI.Button href={callbackLink} className="primary-button large">
                  {t('api_tokens_created_callback_btn')}
                </UI.Button>
              </div>
              <p className="mbm">
                {t('api_tokens_created_callback_description')}{' '}
                <samp
                  className="f5 code ui-container bordered rounded phs"
                  style={{ display: 'inline-block' }}>
                  {get.secret}
                </samp>
              </p>
            </div>
          )}
          <table className="block aligned">
            <tbody>
              <tr>
                <td />
                <td />
                <td />
              </tr>
              <TokenRow {...get} />
            </tbody>
          </table>
          {!!indexAction && (
            <div className="ui-actions mtm">
              <UI.Button href={indexAction} className="button">
                {t('api_tokens_created_back_btn')}
              </UI.Button>
            </div>
          )}
        </div>
      </div>
    )
  }
}

module.exports = TokenCreatedPage
