import React from 'react'
import f from 'lodash'
import { TokenRow } from './Tokens'
import ui from '../../lib/ui.coffee'
import UI from '../../ui-components/index.coffee'
const t = ui.t

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
            <samp className='title-m code b'>
              {get.secret}
            </samp>
          </p>
          <table className='block aligned'>
            <thead>
              <tr>
                <td>
                  <span className='ui-resources-table-cell-content'>
                    {t('api_tokens_head_id')}
                  </span>
                </td>
                <td>
                  <span className='ui-resources-table-cell-content'>
                    {t('api_tokens_head_name')}
                  </span>
                </td>
                <td>
                  <span className='ui-resources-table-cell-content'>
                    {t('api_tokens_head_valid_since')}
                  </span>
                </td>
                <td>
                  <span className='ui-resources-table-cell-content'>
                    {t('api_tokens_head_valid_until')}
                  </span>
                </td>
                <td>
                  <span className='ui-resources-table-cell-content'>
                    {t('api_tokens_head_permissions')}
                  </span>
                </td>
                <td>
                </td>
              </tr>
            </thead>
            <tbody>
              <TokenRow {...get} />
            </tbody>
          </table>
          {!!indexAction &&
            <div className='ui-actions mtm'>
              <UI.Button href={indexAction} className='button'>
                {t('api_tokens_created_back_btn')}
              </UI.Button>
            </div>}
        </div>
      </div>
    )
  }
}

module.exports = TokenCreatedPage
