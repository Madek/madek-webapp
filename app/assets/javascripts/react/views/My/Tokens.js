import React from 'react'
import f from 'lodash'
import ui from '../../lib/ui.coffee'
import Moment from 'moment'
const t = ui.t('de')
Moment.locale('de')

const UI = require('../../ui-components/index.coffee')
const RailsForm = require('../../lib/forms/rails-form.cjsx')

// config
const SECTIONS = [ { key: 'api_tokens', name: 'API Tokens' } ]

class TokensPage extends React.Component {
  render (props = this.props) {
    const { get, authToken } = props

    const newAction = f.get(get, 'actions.new')

    return (
      <div className='ui-resources-holder pal'>
        {SECTIONS.map(({ key, name }) => (
          <div className='ui-container pbl' key={key}>
            <div className='ui-resources-header'>
              <h2 className='title-l ui-resources-title'>
                {name}
              </h2>
            </div>
            <TokensList tokens={get[key]} authToken={authToken} />
            {!!newAction && (
              <div className='mtl'>
                <UI.Button
                  href={newAction.url}
                  className='primary-button'
                      >
                        Neuen Token erstellen
                      </UI.Button>
              </div>
                  )}
          </div>
          ))}
      </div>
    )
  }
}

const TokensList = ({ tokens, authToken }) => {
  const revokedTokens = f.filter(tokens, 'revoked')
  const activeTokens = f.difference(tokens, revokedTokens)
  const allTokes = [
    [ activeTokens ],
    [ revokedTokens, t('api_tokens_list_revoked_title') ]
  ]

  return (
    <div>
      {allTokes.map(([ tokens, label ]) => (
        <div>
          {!!label && <h4 className='title-s mtl mbm'>{label}</h4>}
          <table className='ui-workgroups bordered block aligned'>
            <tbody>
              {
                  f.map(tokens, token => (
                    <TokenRow {...token} authToken={authToken} />
                  ))
                }
            </tbody>
          </table>
        </div>
        ))}
    </div>
  )
}

export const TokenRow = ({ authToken, ...token }) => {
  const { uuid, label, description, revoked, scopes } = token
  let creationDate, creationDateTitle, expirationDate, expirationDateTitle
  if (token.created_at) {
    creationDate = Moment(new Date(token.created_at)).calendar()
    creationDateTitle = `Erstellt: ${token.created_at}`
  }
  if (token.expires_at) {
    expirationDate = Moment(new Date(token.expires_at)).fromNow()
    expirationDateTitle = `Ablaufdatum: ${token.expires_at}`
  }
  const revokeAction = f.get(token, 'actions.update')
  const perms = [ [ 'read', 'Lesen' ], [ 'write', 'Schreiben' ] ]
  const permissionsList = f.compact(
    perms.map(
      ([ key, label ]) => `${label}: ${f.includes(scopes, key) ? 'Ja' : 'Nein'}`
    )
  )

  const trStyle = !revoked ? {} : { opacity: 0.67 }

  return (
    <tr key={uuid} style={trStyle}>
      <td>
        {label}
      </td><td>
        <p className='measure-narrow'>
          {description || '(Keine Beschreibung)'}
        </p>
      </td>
      <td>
        {!!creationDate && (
        <UI.Tooltipped text={creationDateTitle} id={`dtc.${uuid}`}>
          <span>seit {creationDate}</span>
        </UI.Tooltipped>
            )}
      </td>
      <td>
        {!!expirationDate && (
        <UI.Tooltipped text={expirationDateTitle} id={`dtc.${uuid}`}>
          <span>bis {expirationDate}</span>
        </UI.Tooltipped>
            )}
      </td>
      <td>
        Zugriff: {permissionsList.join(', ')}.
      </td>
      <td className='ui-workgroup-actions'>
        {!!revokeAction && (
        <RailsForm
          authToken={authToken}
          method={revokeAction.method}
          action={revokeAction.url}
              >
          <input name='api_token[revoked]' value='true' type='hidden' />
          <UI.Tooltipped
            text={'Token zur\xFCckziehen'}
            id={`btnrv.${uuid}`}
                >
            <button
              className='button'
              type='submit'
              data-confirm='Sind Sie sicher, dass Sie diesen Token zurückziehen wollen?'
                  >
              <i className='fa fa-ban' />
            </button>
          </UI.Tooltipped>
        </RailsForm>
            )}
      </td>
    </tr>
  )
}

module.exports = TokensPage
TokensPage.TokenRow = TokenRow
