/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'lodash'
import t from '../../lib/i18n-translate.js'
import RailsForm from '../lib/forms/rails-form.jsx'
import cx from 'classnames'
let AutoComplete = null

module.exports = createReactClass({
  displayName: 'GroupSearch',

  getInitialState() {
    return {
      mounted: false,
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
        })()
      }
    }
  },

  componentDidMount() {
    AutoComplete = require('../lib/autocomplete.js')
    return this.setState({ mounted: true })
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

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get } = param
    return (
      <div className="form-body bright">
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

const Link = createReactClass({
  render(param) {
    if (param == null) {
      param = this.props
    }
    const { onClick, disabled, enabledClasses } = param
    if (disabled === true) {
      return <span className={cx(enabledClasses, { disabled: true })} />
    } else {
      return <a onClick={onClick} className={enabledClasses} />
    }
  }
})

var MemberRow = createReactClass({
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
