/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../../lib/i18n-translate.js')
const Moment = require('moment')
const currentLocale = require('../../../lib/current-locale.js')

const PageHeader = require('../../ui-components/PageHeader.js')
const HeaderPrimaryButton = require('../HeaderPrimaryButton.cjsx')
const Button = require('../../ui-components/Button.cjsx')
const RailsForm = require('../../lib/forms/rails-form.cjsx')

module.exports = React.createClass({
  displayName: 'Shared.CustomUrls',

  _renderCustomUrlRow(
    uuid,
    created_at_timestamp,
    creator_name,
    creator_login,
    is_primary,
    action_url,
    resource_type,
    auth_token,
    url
  ) {
    let setPrimary
    const created_at = Moment(created_at_timestamp).calendar()
    const creator = creator_name + ' [' + creator_login + ']'
    const type = is_primary
      ? t('edit_custom_urls_state_primary')
      : t('edit_custom_urls_state_transfer')

    if (!is_primary) {
      setPrimary = (
        <RailsForm
          name="resource_meta_data"
          action={action_url}
          method="patch"
          authToken={auth_token}>
          <button className="button" type="submit">
            {t('edit_custom_urls_set_primary')}
          </button>
        </RailsForm>
      )
    }

    return (
      <tr key={uuid}>
        <td>
          <a href={url}>{uuid}</a>
        </td>
        <td>{created_at}</td>
        <td>{creator}</td>
        <td>{type}</td>
        <td style={{ textAlign: 'right' }}>{setPrimary}</td>
      </tr>
    )
  },

  _renderCustomUrl(custom_url) {
    return this._renderCustomUrlRow(
      custom_url.uuid,
      custom_url.created_at,
      custom_url.creator.name,
      custom_url.creator.login,
      custom_url['primary?'],
      custom_url.set_primary_custom_url,
      this.props.get.resource.type,
      this.props.authToken,
      custom_url.url
    )
  },

  _renderUuidRow(resource, creator, any_primary_address) {
    return this._renderCustomUrlRow(
      resource.uuid,
      resource.created_at,
      creator.name,
      creator.login,
      !any_primary_address,
      resource.set_primary_custom_url,
      resource.type,
      this.props.authToken,
      resource.url
    )
  },

  _anyPrimaryAddress(custom_urls) {
    return !f.isEmpty(f.filter(custom_urls, { 'primary?': true }))
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { get, title } = param
    Moment.locale(currentLocale())

    const { resource } = get

    title = t('custom_urls_title') + '"' + resource.title + '"'

    const headerButton = (
      <HeaderPrimaryButton
        key="new_custom_url"
        icon={null}
        text={t('custom_urls_new')}
        href={get.edit_url}
      />
    )

    const backText = t(
      `edit_custom_urls_back_to_${f.kebabCase(this.props.get.type).replace('-', '_')}`
    )

    return (
      <div>
        <PageHeader icon={null} title={title} actions={[headerButton]} />
        <div className="bright ui-container pal bordered rounded">
          <div className="row" style={{ color: '#9a9a9a' }}>
            <div className="col1of2">
              <div className="ui-info-box prm mbs">
                <h2 className="title-l ui-info-box-title mbs">{t('custom_urls_primary_title')}</h2>
                {t('custom_urls_primary_hint')}
              </div>
            </div>
            <div className="col1of2">
              <div className="ui-info-box plm mbs">
                <h2 className="title-l ui-info-box-title mbs">
                  {t('custom_urls_canonical_title')}
                </h2>
                {t('custom_urls_canonical_hint')}
              </div>
            </div>
          </div>
          <hr className="separator mvl" />
          <div>
            <h2 className="title-l mbs">{t('custom_urls_manage_address_title')}</h2>
            <table className="ui-rights-group bordered block">
              <thead>
                <tr>
                  <td style={{ width: '30%' }}>{t('custom_urls_table_header_address')}</td>
                  <td style={{ width: '20%' }}>{t('custom_urls_table_header_date')}</td>
                  <td style={{ width: '20%' }}>{t('custom_urls_table_header_created_by')}</td>
                  <td style={{ width: '10%' }}>{t('custom_urls_table_header_type')}</td>
                  <td style={{ width: '20%', textAlign: 'right' }}>
                    {t('custom_urls_table_header_actions')}
                  </td>
                </tr>
              </thead>
              <tbody>
                {this._renderUuidRow(
                  get.resource,
                  get.resource_creator,
                  this._anyPrimaryAddress(get.custom_urls)
                )}
                {f.map(f.sortBy(get.custom_urls, 'created_at').reverse(), custom_url => {
                  return this._renderCustomUrl(custom_url)
                })}
              </tbody>
            </table>
            <div className="ui-actions phl pbl mtl">
              <a className="button" href={this.props.get.resource.url}>
                {' '}
                {backText}{' '}
              </a>
            </div>
          </div>
        </div>
      </div>
    )
  }
})
