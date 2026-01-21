/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Permissions View for a single resource, can be show or (inline-)edit
// - has internal router to switch between show/edit by URL

import React from 'react'
import t from '../../lib/i18n-translate.js'
import url from 'url'
import ResourcePermissionsForm from '../decorators/ResourcePermissionsForm.jsx'
import Modal from '../ui-components/Modal.jsx'
import EditTransferResponsibility from '../views/Shared/EditTransferResponsibility.jsx'
import CollectionPermissions from '../../models/collection/permissions.js'
import MediaEntryPermissions from '../../models/media-entry/permissions.js'

class ResourcePermissions extends React.Component {
  constructor(props) {
    super(props)
    this.state = { editing: false, saving: false, transferModal: false }
    this._toBeCalledOnUnmount = []

    const model = (() => {
      if (this.props.get.isState) {
        return this.props.get
      } else {
        const PermissionsModel =
          this.props.get.type === 'Collection' ? CollectionPermissions : MediaEntryPermissions
        return new PermissionsModel(this.props.get)
      }
    })()

    // set up auto-update for model:
    ;['add', 'remove', 'reset', 'change'].forEach(eventName => {
      return model.on(eventName, () => this.forceUpdate())
    })

    this.state.model = model
  }

  _showTransferModal = show => {
    return this.setState({ transferModal: show })
  }

  componentWillUnmount() {
    return this._toBeCalledOnUnmount.forEach(fn => fn())
  }

  componentDidMount() {
    const router = require('../../lib/router.js')

    const editUrl = url.parse(this.props.get.edit_permissions_url).pathname

    // setup router:

    // set state according to url from router
    const stopListen = router.listen(location => {
      // runs once initially when router is started!
      return this.setState({ editing: location.pathname === editUrl })
    })
    this._toBeCalledOnUnmount.push(stopListen)

    const stopConfirming = router.confirmNavigation({
      check: () => this.state.editing || this.state.saving
    })
    this._toBeCalledOnUnmount.push(stopConfirming)

    // "attach" and start the router
    this._router = router // internal ref, NOT in state!
    return router.start()
  }

  _onStartEdit = event => {
    if (event != null) {
      event.preventDefault()
    }
    return this._router.goTo(event.target.href)
  }

  _onCancelEdit = () => {}

  _onSubmitForm = event => {
    event.preventDefault()
    this.setState({ saving: true })
    return this.state.model.save({
      success: model => {
        this.setState({ saving: false, editing: false })
        return this._router.goTo(model.url)
      },
      error: (_, err) => {
        this.setState({ saving: false, editing: true })
        alert(
          `Error! ${
            (() => {
              try {
                return JSON.stringify((err != null ? err.body : undefined) || err, 0, 2)
                // eslint-disable-next-line no-unused-vars
              } catch (e) {
                // just silently fall back and alert an empty string. Mh.
              }
            })() || ''
          }`
        )
        return console.error(err)
      }
    })
  }

  render() {
    let transferClick
    const { optionals } = this.props
    const { model, editing, saving } = this.state

    const GroupIndex = ({ subject }) => (
      <span className="text" title={subject.detailed_name}>
        {subject.can_show ? (
          <a href={subject.url}>{subject.detailed_name}</a>
        ) : (
          subject.detailed_name
        )}
      </span>
    )

    if (this.props.get.can_transfer) {
      transferClick = event => this._showTransferModal(true, event)
    }

    return (
      <div>
        {this.state.transferModal ? (
          <Modal widthInPixel={800}>
            <EditTransferResponsibility
              authToken={this.props.authToken}
              batch={false}
              resourceType={this.props.get.type}
              singleResourceUrl={this.props.get.resource_url}
              singleResourceFallbackUrl={this.props.get.fallback_url}
              singleResourcePermissionsUrl={this.props.get.permissions_url}
              singleResourceActionUrl={this.props.get.update_transfer_responsibility_url}
              batchResourceIds={null}
              responsible={this.props.get.responsible}
              onClose={event => this._showTransferModal(false, event)}
              currentUser={this.props.get.current_user}
            />
          </Modal>
        ) : undefined}
        <ResourcePermissionsForm
          get={model}
          editing={editing}
          saving={saving}
          optionals={optionals}
          onEdit={this._onStartEdit}
          onSubmit={this._onSubmitForm}
          onCancel={this._onCancelEdit}
          editUrl={this.props.get.edit_permissions_url}
          decos={{ Groups: GroupIndex }}>
          <PermissionsOverview get={model} openTransferModal={transferClick} />
          <hr className="separator light mvl" />
          <h3 className="title-l mbs">{t('permissions_table_title')}</h3>
        </ResourcePermissionsForm>
      </div>
    )
  }
}

class PermissionsOverview extends React.Component {
  render() {
    const { get } = this.props

    return (
      <div className="row">
        <h3 className="title-l mbl">{t('permissions_responsibility_title')}</h3>
        <div className="col1of2">
          <div className="ui-info-box">
            <h2 className="ui-rights-user-title mbs" style={{ fontWeight: '700' }}>
              {t('permissions_responsible_user_and_responsibility_group_title')}
            </h2>
            <p className="ui-info-box-intro prm">
              {t('permissions_responsible_user_and_responsibility_group_msg')}
            </p>
            <ul className="inline">
              <li className="person-tag">{get.responsible.name}</li>
            </ul>
            {this.props.openTransferModal ? (
              <ul className="inline mts">
                <a className="button" onClick={this.props.openTransferModal}>
                  {t('permissions_transfer_responsibility_link')}
                </a>
              </ul>
            ) : undefined}
          </div>
        </div>
        {get.current_user ? (
          <div className="col1of2">
            <h2 className="ui-rights-user-title mbs" style={{ fontWeight: '700' }}>
              {t('permissions_overview_yours_title')}
            </h2>
            <p className="ui-info-box-intro">
              {t('permissions_overview_yours_msg_start')}
              {get.current_user.name}
              {t('permissions_overview_yours_msg_end')}
            </p>
            <ul className="inline">
              {get.current_user_permissions.map(p => (
                <li key={p}>{t(`permission_name_${p}`)}</li>
              ))}
            </ul>
          </div>
        ) : undefined}
      </div>
    )
  }
}

export default ResourcePermissions
