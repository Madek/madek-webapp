import React from 'react'
import f from 'lodash'
import { ConfidentialLinkHead, ConfidentialLinkRow } from './ConfidentialLinks'
import ui from '../../lib/ui.coffee'
import UI from '../../ui-components/index.coffee'
const t = ui.t

class ConfidentialLinkCreated extends React.Component {
  render(props = this.props) {
    const { get } = props
    const justCreated = f.get(get, 'just_created', false)
    const indexAction = f.get(get, 'actions.index.url')
    const title = justCreated
      ? t('confidential_links_created_title')
      : t('confidential_links_show_title')

    return (
      <div className="by-center" style={{ marginLeft: 'auto', marginRight: 'auto' }}>
        <div
          className="ui-container bright bordered rounded phl pbs"
          style={{ display: 'inline-block' }}>
          <h3 className="title-l mam">{title}</h3>
          {get.revoked && (
            <h4 className="title-s mas" style={{ color: 'darkred' }}>
              revoked
            </h4>
          )}

          <table className="block aligned mbm">
            <ConfidentialLinkHead />
            <tbody>
              <ConfidentialLinkRow {...get} />
            </tbody>
          </table>

          <div style={{ maxWidth: '60em' }}>
            <details open className="mbm" onClick={e => e.preventDefault()}>
              <summary>{t('confidential_links_show_link_for_copy')}</summary>
              <p
                className="ui-container bordered rounded xmam phl pbs"
                style={{ wordBreak: 'break-all' }}>
                <a href={get.secret_url} target="_blank">
                  <samp className="title-m code b">{get.secret_url}</samp>
                </a>
              </p>
            </details>

            <details className="mbm">
              <summary>{t('confidential_links_show_embedcode_for_copy')}</summary>
              <SelectingTextarea className="code block pas">
                {get.embed_html_code}
              </SelectingTextarea>
            </details>
          </div>

          {!!indexAction && (
            <div className="ui-actions mas pan">
              <UI.Button href={indexAction} className="button">
                {t('confidential_links_created_back_btn')}
              </UI.Button>
              <a className="button" href={get.actions.go_back.url}>
                {t('confidential_links_back_to_media_entry')}
              </a>
            </div>
          )}
        </div>
      </div>
    )
  }
}

module.exports = ConfidentialLinkCreated

const SelectingTextarea = props => {
  const doSelect = event => {
    const { target } = event
    setTimeout(() => {
      // NOTE: Mobile Safari does not support `select()`, use this fallback:
      let selectionLength
      try {
        selectionLength = target.value.length
      } catch (e) {
        selectionLength = 9999
      }
      target.setSelectionRange(0, selectionLength)
      target.focus()
    }, 1)
  }
  return (
    <textarea
      rows="1"
      {...props}
      value={props.value || props.children}
      style={{
        display: 'inline-block',
        textIndent: 0,
        fontSize: '85%',
        minHeight: 0,
        ...props.style
      }}
      onClick={doSelect}
      onFocus={doSelect}
      onChange={doSelect}
    />
  )
}
