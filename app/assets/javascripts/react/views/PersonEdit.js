import React from 'react'
import t from '../../lib/i18n-translate.js'
import f from 'active-lodash'
import cx from 'classnames'
import PageHeader from '../ui-components/PageHeader'
import PageContent from './PageContent.cjsx'
import RailsForm from '../lib/forms/rails-form.cjsx'
import Button from '../ui-components/Button.cjsx'
import Icon from '../ui-components/Icon.cjsx'
import { deco_external_uris } from './PersonShow.cjsx'
import { decorateExternalURI } from '../../lib/URIAuthorityControl'

class PersonEdit extends React.Component {
  constructor(props) {
    super(props)

    const { external_uris } = props.get

    this.state = {
      isSaving: false,
      external_uris: f.map(external_uris, uri => decorateExternalURI(uri))
    }

    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleUriChange = this.handleUriChange.bind(this)
    this.handleUriAdd = this.handleUriAdd.bind(this)
    this.handleUriRemove = this.handleUriRemove.bind(this)
  }

  handleSubmit(e) {
    this.setState({ isSaving: true })
  }

  handleUriChange(e, index) {
    const external_uris = this.state.external_uris.slice(0)
    external_uris[index] = decorateExternalURI(e.target.value)
    this.setState({ external_uris })
  }

  handleUriAdd(e) {
    const external_uris = this.state.external_uris.slice(0)
    external_uris.push(decorateExternalURI(''))
    this.setState({ external_uris })
  }

  handleUriRemove(e, index) {
    e.preventDefault()
    const external_uris = this.state.external_uris.slice(0)
    external_uris.splice(index, 1)
    this.setState({ external_uris })
  }

  render() {
    const { get, authToken } = this.props
    const { actions, to_s } = get
    const { isSaving, external_uris } = this.state
    const title = `${to_s} - ${t('person_edit_editing_header')}`

    return (
      <PageContent>
        <PageHeader title={title} icon="tag" />
        <div className="ui-container tab-content bordered bright rounded-right rounded-bottom pal">
          <RailsForm
            name="person"
            method={actions.update.method}
            action={actions.update.url}
            authToken={authToken}
            onSubmit={this.handleSubmit}>
            <div className="col1of2">
              <div className="ui-form-group rowed pan">
                <label className="form-label">
                  {t('person_show_first_name')}
                  <input
                    type="text"
                    className="form-item block"
                    name={'person[first_name]'}
                    defaultValue={get.first_name}
                  />
                </label>
              </div>
              <div className="ui-form-group rowed pan">
                <label className="form-label">
                  {t('person_show_last_name')}
                  <input
                    type="text"
                    className="form-item block"
                    name={'person[last_name]'}
                    defaultValue={get.last_name}
                  />
                </label>
              </div>
              <div className="ui-form-group rowed pan">
                <label className="form-label">
                  {t('person_show_pseudonym')}
                  <input
                    type="text"
                    className="form-item block"
                    name={'person[pseudonym]'}
                    defaultValue={get.pseudonym}
                  />
                </label>
              </div>
              <div className="ui-form-group rowed pan">
                <label className="form-label">
                  {t('person_show_description')}
                  <textarea
                    className="form-item block"
                    name={'person[description]'}
                    defaultValue={get.description}
                  />
                </label>
              </div>
            </div>
            <div className="row">
              <ExternalUrisForm
                externalUris={external_uris}
                handleUriChange={this.handleUriChange}
                handleUriAdd={this.handleUriAdd}
                handleUriRemove={this.handleUriRemove}
              />
              <div className="ui-actions mtm">
                <input
                  type="submit"
                  className="primary-button"
                  disabled={isSaving}
                  value={t('person_edit_save_btn')}
                />
                <Button href={actions.cancel.url} className={cx('button')} disabled={!!isSaving}>
                  {t('person_edit_cancel_btn')}
                </Button>
              </div>
            </div>
          </RailsForm>
        </div>
      </PageContent>
    )
  }
}

const ExternalUrisForm = props => {
  const { externalUris, handleUriChange, handleUriRemove, handleUriAdd } = props

  const divStyle = { display: 'flex', alignItems: 'baseline' }
  const previewStyle = { paddingTop: '4px', fontWeight: 600 }

  return (
    <div className="ui-container">
      <div className="row">
        <div className="col1of2">
          <h3 className="title-m separated mbm ptm">{t('person_show_external_uris')}</h3>
        </div>
        <div className="col1of2">
          <div className="ui-container pll">
            <h3 className="title-m separated mbm ptm">{t('person_edit_preview')}</h3>
          </div>
        </div>
      </div>
      {f.map(externalUris, (uri, index) => (
        <div className="row" key={index}>
          <div className="col1of2">
            <div className="ui-form-group rowed pan" style={divStyle}>
              <button type="button" onClick={e => handleUriRemove(e, index)} className="mrx button">
                <Icon i="trash" />
              </button>
              <input
                type="text"
                className="form-item block"
                name={'person[external_uris][]'}
                value={uri.uri}
                onChange={e => handleUriChange(e, index)}
                style={{ display: 'inline-block' }}
              />
            </div>
          </div>
          <div className="col1of2">
            <div className="ui-container pll preview">
              <div style={previewStyle}>{deco_external_uris([uri])}</div>
            </div>
          </div>
        </div>
      ))}
      <button type="button" onClick={handleUriAdd} className="primary-button">
        {t('person_edit_add_uri_btn')}
      </button>
    </div>
  )
}

module.exports = PersonEdit
