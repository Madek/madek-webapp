/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const f = require('lodash')
const t = require('../../lib/i18n-translate.js')
const RailsForm = require('../lib/forms/rails-form.jsx')
const classnames = require('classnames')
let AutoComplete = null
const AskModal = require('../ui-components/AskModal.jsx')
const loadXhr = require('../../lib/load-xhr.js')

module.exports = React.createClass({
  displayName: 'GroupSearch',

  getInitialState() {
    return {
      mounted: false,
      askDialog: false,
      askFailure: false,
      loading: false,
      data: {
        initialUserIdList: f.map(this.props.get.members, 'uuid'),
        userIdList: f.map(this.props.get.members, 'uuid'),
        users: (() => {
          const result = {}
          f.each(
            this.props.get.members,
            member =>
              (result[member.uuid] = {
                id: member.uuid,
                name: member.name,
                login: member.login,
                checked: true
              })
          )
          return result
        })(),
        failure: null
      }
    }
  },

  componentDidMount() {
    AutoComplete = require('../lib/autocomplete.js')
    return this.setState({ mounted: true })
  },

  _onDelete() {
    this.state.data.failure = null
    return this.setState({ askDialog: true })
  },

  _onSelect(subject) {
    const user = {
      id: subject.uuid,
      name: subject.name,
      login: subject.login,
      checked: true
    }

    const { data } = this.state
    if (!f.includes(data.userIdList, user.id)) {
      data.userIdList.push(user.id)
      data.users[user.id] = user
    }
    return this.setState({})
  },

  _onRemove(userId) {
    const { data } = this.state
    data.users[userId].checked = false
    f.pull(data.userIdList, userId)
    return this.setState({})
  },

  _onModalOk() {
    this.state.data.failure = null
    this.setState({ loading: true })
    return loadXhr(
      {
        method: 'DELETE',
        url: this.props.get.url,
        body: {
          authToken: this.props.authToken
        }
      },
      (result, data) => {
        if (result === 'success') {
          return (window.location = this.props.get.success_url)
        } else {
          this.state.data.failure = data.headers[0]
          return this.setState({ loading: false })
        }
      }
    )
  },

  _onModalCancel() {
    return this.setState({ askDialog: false })
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    return (
      <div className="form-body bright">
        {this.state.askDialog ? (
          <AskModal
            title={t('group_ask_delete_title')}
            error={this.state.data.failure}
            loading={this.state.loading}
            onCancel={this._onModalCancel}
            onOk={this._onModalOk}
            okText={t('group_ask_delete_delete')}
            cancelText={t('group_ask_delete_cancel')}>
            <p className="pam by-center">
              {t('group_ask_delete_question_pre')}
              <strong>{get.name}</strong>
              {t('group_ask_delete_question_post')}
            </p>
          </AskModal>
        ) : (
          undefined
        )}
        <RailsForm name="group" action={get.url} method="put" authToken={authToken}>
          <div className="ui-form-group rowed">
            <label className="form-label" htmlFor="group_name">
              {t('group_edit_name')}
            </label>
            <input
              type="text"
              className="form-item"
              style={{ width: '100%' }}
              name="group[name]"
              defaultValue={get.name}
              placeholder=""
            />
          </div>
          <div className="ui-form-group rowed">
            {f.map(this.state.data.initialUserIdList, userId => (
              <input
                key={`hidden_false_${userId}`}
                type="hidden"
                name={`group[users][${userId}]`}
                value={false}
              />
            ))}
            {f.map(this.state.data.userIdList, userId => (
              <input
                key={`hidden_true_${userId}`}
                type="hidden"
                name={`group[users][${userId}]`}
                value={true}
              />
            ))}
            <h3 className="title-l mbs">{t('group_edit_member')}</h3>
            <table className="ui-rights-group">
              <thead>
                <tr>
                  <td className="ui-rights-user-title" style={{ borderColor: '#f3f3f3' }}>
                    {t('group_edit_person')}
                  </td>
                </tr>
              </thead>
              <tbody>
                {f.map(this.state.data.userIdList, userId => {
                  const user = this.state.data.users[userId]
                  return (
                    <MemberRow
                      key={`row_${userId}`}
                      user={user}
                      onRemove={this._onRemove}
                      disabled={this.state.data.userIdList.length <= 1}
                    />
                  )
                })}
              </tbody>
            </table>
            {AutoComplete ? (
              <div className="ui-add-subject ptx row" style={{ zIndex: '1000' }}>
                <div className="col1of3">
                  <AutoComplete
                    className="multi-select-input"
                    name="group[user][login][]"
                    resourceType="Users"
                    onSelect={this._onSelect}
                  />
                </div>
              </div>
            ) : (
              undefined
            )}
          </div>
          {false ? (
            // Delete link with confirm modal. Not used anymore, but I am sure it will come back one day.
            <div className="ui-form-group rowed">
              {t('group_edit_at_least_one_member_pre')}
              <a onClick={this._onDelete}>{t('group_edit_at_least_one_member_delete')}</a>
              {t('group_edit_at_least_one_member_post')}
            </div>
          ) : (
            undefined
          )}
          {!f.includes(this.state.data.userIdList, get.current_user_id) ? (
            <div className="form-head">
              <div className="ui-alerts">
                <div className="ui-alert warning">{t('group_edit_hint_remove_yourself')}</div>
              </div>
            </div>
          ) : (
            undefined
          )}
          <div className="ui-actions phl pbl mtl">
            <a href={get.cancel_url} className="link weak">
              {t('group_edit_cancel')}
            </a>
            <button type="submit" className="primary-button large">
              {t('group_edit_save')}
            </button>
          </div>
        </RailsForm>
      </div>
    )
  }
})

const Link = React.createClass({
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { onClick, disabled, enabledClasses } = param
    if (disabled === true) {
      return <span className={classnames(enabledClasses, { disabled: true })} />
    } else {
      return <a onClick={onClick} className={enabledClasses} />
    }
  }
})

var MemberRow = React.createClass({
  _onRemove() {
    if (!this.props.disabled) {
      return this.props.onRemove(this.props.user.id)
    }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { user } = param
    const Elm = this.props.disabled ? 'span' : 'a'

    return (
      <tr>
        <td className="ui-rights-user" style={{ borderColor: '#f3f3f3' }}>
          <Link
            disabled={this.props.disabled}
            onClick={this._onRemove}
            enabledClasses="button small ui-rights-remove icon-close small"
          />
          <span className="text">{user.name}</span>
        </td>
      </tr>
    )
  }
})
