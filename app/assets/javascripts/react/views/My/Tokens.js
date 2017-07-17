import React from 'react'
import f from 'lodash'
import ui from '../../lib/ui.coffee'
import Moment from 'moment'
const t = ui.t('de')
Moment.locale('de')

const UI = require('../../ui-components/index.coffee')
const RailsForm = require('../../lib/forms/rails-form.cjsx')

// config
const SECTIONS = [{ key: 'api_tokens', name: 'API Tokens' }]

class TokensPage extends React.Component {
  render (props = this.props) {
    const { get, authToken } = props

    const newAction = f.get(get, 'actions.new')

    return (
      <div className='ui-resources-holder pal'>
        {SECTIONS.map(({ key, name }) =>
          <div className='ui-container pbl' key={key}>
            <div className='ui-resources-header'>
              <h2 className='title-l ui-resources-title'>
                {name}
              </h2>
            </div>
            <TokensList tokens={get[key]} authToken={authToken} />
            {!!newAction &&
              <div className='mtl'>
                <UI.Button href={newAction.url} className='primary-button'>
                  {t('api_tokens_list_new_button')}
                </UI.Button>
              </div>}
          </div>
        )}
      </div>
    )
  }
}

const TokensList = ({ tokens, authToken }) => {
  const revokedTokens = f.filter(tokens, 'revoked')
  const activeTokens = f.difference(tokens, revokedTokens)
  const allTokes = f.compact([
    [activeTokens],
    !f.isEmpty(revokedTokens) && [
      revokedTokens,
      t('api_tokens_list_revoked_title')
    ]
  ])

  return (
    <div>
      {allTokes.map(([tokens, label]) =>
        <div>
          {!!label &&
            <h4 className='title-s mtl mbm'>
              {label}
            </h4>}
          <table className='ui-workgroups bordered block aligned'>
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
              {f.map(tokens, token =>
                <TokenRow {...token} authToken={authToken} />
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

export const TokenRow = ({ authToken, ...token }) => {
  const { uuid, label, description, revoked, scopes } = token
  let creationDate, creationDateTitle, expirationDate, expirationDateTitle
  if (token.created_at) {
    creationDate = Moment(new Date(token.created_at)).calendar()
    creationDateTitle = t('api_tokens_list_created_hint_pre') + token.created_at
  }
  if (token.expires_at) {
    expirationDate = Moment(new Date(token.expires_at)).fromNow()
    expirationDateTitle =
      t('api_tokens_list_expires_hint_pre') + token.expires_at
  }
  const revokeAction = f.get(token, 'actions.update')
  const perms = [
    ['read', t('api_tokens_list_scope_read')],
    ['write', t('api_tokens_list_scope_write')]
  ]
  const permissionsList = f.compact(
    perms.map(([key, label]) => {
      const stateLabel = f.includes(scopes, key)
        ? t('api_tokens_list_scope_on')
        : t('api_tokens_list_scope_off')
      return `${label}: ${stateLabel}`
    })
  )

  const trStyle = !revoked ? {} : { opacity: 0.67 }

  return (
    <tr key={uuid} style={trStyle}>
      <td>
        {label}
      </td>
      <td>
        <pre className='measure-narrow'>
          {!f.isEmpty(description)
            ? description
            : t('api_tokens_list_no_description')}
        </pre>
      </td>
      <td>
        {!!creationDate &&
          <UI.Tooltipped text={creationDateTitle} id={`dtc.${uuid}`}>
            <span>
              {creationDate}
            </span>
          </UI.Tooltipped>}
      </td>
      <td>
        {!!expirationDate &&
          <UI.Tooltipped text={expirationDateTitle} id={`dtc.${uuid}`}>
            <span>
              {expirationDate}
            </span>
          </UI.Tooltipped>}
      </td>
      <td>
        {permissionsList.join(', ')}
      </td>
      <td className='ui-workgroup-actions'>
        {!!revokeAction &&
          <RailsForm
            name={'api_token'}
            authToken={authToken}
            method={revokeAction.method}
            action={revokeAction.url}
          >
            <input name='api_token[revoked]' value='true' type='hidden' />
            <UI.Tooltipped
              text={t('api_tokens_list_revoke_btn_hint')}
              id={`btnrv.${uuid}`}
            >
              <button
                className='button'
                type='submit'
                data-confirm={t('api_tokens_list_revoke_confirm')}
              >
                <i className='fa fa-ban' />
              </button>
            </UI.Tooltipped>
          </RailsForm>}
      </td>
    </tr>
  )
}

module.exports = TokensPage
TokensPage.TokenRow = TokenRow
