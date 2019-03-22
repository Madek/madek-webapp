import React from 'react'
import RailsForm from '../../lib/forms/rails-form.cjsx'
import PageHeader from '../../ui-components/PageHeader'
import f from 'lodash'
import Moment from 'moment'
import ui from '../../lib/ui.coffee'
import currentLocale from '../../../lib/current-locale'
import Link from '../../ui-components/Link.cjsx'
const t = ui.t

const UI = require('../../ui-components/index.coffee')

class ConfidentialLinks extends React.Component {
  render() {
    const { get, authToken } = this.props
    const confidentialLinksList = get.list
    const newAction = f.get(get, 'actions.new')
    const title = t('confidential_links_title_pre') + '"' + get.resource.title + '"'

    const newButton = !!newAction && (
      <div className="mtl">
        <UI.Button href={newAction.url} className="primary-button">
          {t('confidential_links_list_new_button')}
        </UI.Button>
      </div>
    )

    return (
      <div>
        <PageHeader icon={null} title={title} actions={null} />

        <div className="bright ui-container pal bordered rounded">
          <div>
            <div className="ui-resources-holder pal">
              <div className="ui-container pbl">
                <div className="ui-resources-header">
                  <h2 className="title-l ui-resources-title">{t('confidential_links_header')}</h2>
                </div>
                <ConfidentialLinksList
                  list={confidentialLinksList}
                  actions={[newButton]}
                  authToken={authToken}
                />
              </div>
            </div>
            <div className="ui-actions phl pbl">
              <a className="button" href={get.actions.go_back.url}>
                {t('confidential_links_back_to_media_entry')}
              </a>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const ConfidentialLinksList = ({ list, actions, authToken }) => {
  const expiredUrls = f.filter(list, 'is_expired')
  const activeUrls = f.difference(list, expiredUrls)
  const allUrls = f.compact([
    [activeUrls],
    !f.isEmpty(expiredUrls) && [expiredUrls, t('confidential_links_list_revoked_title')]
  ])

  return (
    <div>
      {allUrls.map(([urls, label], i) => (
        <div key={i}>
          {!!label && <h4 className="title-s mtl mbm">{label}</h4>}
          <table className="ui-workgroups bordered block aligned">
            <ConfidentialLinkHead />
            <tbody>
              {f.map(urls, url => (
                <ConfidentialLinkRow key={url.uuid} {...url} authToken={authToken} />
              ))}
            </tbody>
          </table>
          {i == 0 && f.map(actions)}
        </div>
      ))}
    </div>
  )
}

const ConfidentialLinkHead = () => (
  <thead>
    <tr>
      <td>
        <span className="ui-resources-table-cell-content">
          {t('confidential_links_head_token')}
        </span>
      </td>
      <td>
        <span className="ui-resources-table-cell-content">{t('confidential_links_head_name')}</span>
      </td>
      <td>
        <span className="ui-resources-table-cell-content">
          {t('confidential_links_head_valid_since')}
        </span>
      </td>
      <td>
        <span className="ui-resources-table-cell-content">
          {t('confidential_links_head_valid_until')}
        </span>
      </td>
      <td />
      <td />
    </tr>
  </thead>
)

const ConfidentialLinkRow = ({ authToken, ...confidentialLink }) => {
  Moment.locale(currentLocale())
  const { uuid, label, description, is_expired } = confidentialLink
  let creationDate, creationDateTitle, expirationDate, expirationDateTitle
  if (confidentialLink.created_at) {
    creationDate = Moment(new Date(confidentialLink.created_at)).calendar()
    creationDateTitle = t('confidential_links_list_created_hint_pre') + confidentialLink.created_at
  }
  if (confidentialLink.expires_at) {
    expirationDate = Moment(new Date(confidentialLink.expires_at)).fromNow()
    expirationDateTitle =
      t('confidential_links_list_expires_hint_pre') + confidentialLink.expires_at
  } else {
    expirationDate = t('confidential_links_list_no_expiry')
    expirationDateTitle = `${t('confidential_links_list_expires_hint_pre')}${expirationDate}`
  }
  const showAction = f.get(confidentialLink, 'actions.show')
  const revokeAction = f.get(confidentialLink, 'actions.revoke')
  const trStyle = !is_expired ? {} : { opacity: 0.67 }

  return (
    <tr key={uuid} style={trStyle}>
      <td>
        {f.isString(label) && label.slice(0, 6)}
        {'…'}
      </td>
      <td>
        <div className="measure-narrow">
          {!f.isEmpty(description) ? description : t('confidential_links_list_no_description')}
        </div>
      </td>
      <td>
        {!!creationDate && (
          <UI.Tooltipped text={creationDateTitle} id={`dtc.${uuid}`}>
            <span>{creationDate}</span>
          </UI.Tooltipped>
        )}
      </td>
      <td>
        {!!expirationDate && (
          <UI.Tooltipped text={expirationDateTitle} id={`dtc.${uuid}`}>
            <span>{expirationDate}</span>
          </UI.Tooltipped>
        )}
      </td>
      <td>
        {!!showAction && <Link href={showAction.url}>{t('confidential_links_list_show_url')}</Link>}
      </td>
      <td className="ui-workgroup-actions">
        {!!revokeAction && (
          <RailsForm
            name={'confidential_link'}
            authToken={authToken}
            method={revokeAction.method}
            action={revokeAction.url}>
            <input name="confidential_link[revoked]" value="true" type="hidden" />
            <UI.Tooltipped text={t('confidential_links_list_revoke_btn_hint')} id={`btnrv.${uuid}`}>
              <button
                className="button"
                type="submit"
                data-confirm={t('confidential_links_list_revoke_confirm')}>
                <i className="fa fa-ban" />
              </button>
            </UI.Tooltipped>
          </RailsForm>
        )}
      </td>
    </tr>
  )
}

module.exports = ConfidentialLinks
ConfidentialLinks.ConfidentialLinkHead = ConfidentialLinkHead
ConfidentialLinks.ConfidentialLinkRow = ConfidentialLinkRow
