import React from 'react'
import f from 'lodash'
import Moment from 'moment'
import { TokenRow } from './Tokens'
import ui from '../../lib/ui.coffee'
import UI from '../../ui-components/index.coffee'
const t = ui.t('de')
Moment.locale('de')

class TokenCreatedPage extends React.Component {
  render (props = this.props) {
    const { get } = props
    const indexAction = f.get(get, 'actions.index.url')

    return (
      <div
        className='by-center'
        style={{ marginLeft: 'auto', marginRight: 'auto' }}
      >
        <div
          className='ui-container bright bordered rounded mal phl pbs'
          style={{ display: 'inline-block' }}
        >
          <h3 className='title-l mas'>
            {t('api_tokens_created_title')}
          </h3>
          <div className='ui-alerts'>
            <div className='confirmation ui-alert'>
              {t('api_tokens_created_notice')}
            </div>
          </div>
          <p
            className='ui-container bordered rounded mam pas'
            style={{ display: 'inline-block' }}
          >
            <samp className='title-m code b'>{get.secret}</samp>
          </p>
          <table className='block aligned'>
            <tbody>
              <tr><td /><td /><td /></tr>
              <TokenRow {...get} />
            </tbody>
          </table>
          {!!indexAction && (
            <div className='ui-actions mtm'>
              <UI.Button href={indexAction} className='button'>
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
