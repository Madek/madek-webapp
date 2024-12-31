React = require('react')
ReactDOM = require('react-dom')
f = require('lodash')
t = require('../../lib/i18n-translate.js')
RailsForm = require('../lib/forms/rails-form.cjsx')
classnames = require('classnames')
AutoComplete = null
AskModal = require('../ui-components/AskModal.cjsx')
loadXhr = require('../../lib/load-xhr.coffee')


module.exports = React.createClass
  displayName: 'GroupSearch'

  getInitialState: () -> {
    mounted: false
    askDialog: false
    askFailure: false
    loading: false
    data: {
      initialUserIdList: f.map(@props.get.members, 'uuid')
      userIdList: f.map(@props.get.members, 'uuid')
      users: (() =>
        result = {}
        f.each(@props.get.members, (member) ->
          result[member.uuid] = {
            id: member.uuid
            name: member.name
            login: member.login
            checked: true
          }
        )
        result
      )()
      failure: null
    }
  }

  componentDidMount: () ->
    AutoComplete = require('../lib/autocomplete.js')
    @setState(mounted: true)

  _onDelete: () ->
    @state.data.failure = null
    @setState(askDialog: true)

  _onSelect: (subject) ->
    user = {
      id: subject.uuid,
      name: subject.name,
      login: subject.login,
      checked: true
    }

    data = @state.data
    if not f.includes(data.userIdList, user.id)
      data.userIdList.push(user.id)
      data.users[user.id] = user
    @setState({})

  _onRemove: (userId) ->
    data = @state.data
    data.users[userId].checked = false
    f.pull(data.userIdList, userId)
    @setState({})

  _onModalOk: () ->
    @state.data.failure = null
    @setState(loading: true)
    loadXhr(
      {
        method: 'DELETE'
        url: @props.get.url
        body: {
          authToken: @props.authToken
        }
      },
      (result, data) =>
        if result == 'success'
          window.location = @props.get.success_url
        else
          @state.data.failure = data.headers[0]
          @setState(loading: false)
    )

  _onModalCancel: () ->
    @setState(askDialog: false)


  render: ({authToken, get} = @props) ->

    <div className='form-body bright'>

      {
        if @state.askDialog
          <AskModal title={t('group_ask_delete_title')}
            error={@state.data.failure}
            loading={@state.loading}
            onCancel={@_onModalCancel} onOk={@_onModalOk}
            okText={t('group_ask_delete_delete')}
            cancelText={t('group_ask_delete_cancel')}>
            <p className="pam by-center">
              {t('group_ask_delete_question_pre')}
              <strong>{get.name}</strong>
              {t('group_ask_delete_question_post')}
            </p>
          </AskModal>
      }

      <RailsForm name='group' action={get.url}
        method='put' authToken={authToken}>


        <div className="ui-form-group rowed">
          <label className="form-label" htmlFor="group_name">{t('group_edit_name')}</label>
          <input type={'text'} className='form-item' style={{width: '100%'}}
            name={'group[name]'} defaultValue={get.name} placeholder={''} />
        </div>

        <div className="ui-form-group rowed">

          {
            f.map(
              @state.data.initialUserIdList,
              (userId) ->
                <input key={'hidden_false_' + userId} type='hidden'
                  name={'group[users][' + userId + ']'} value={false} />
            )
          }
          {
            f.map(
              @state.data.userIdList,
              (userId) ->
                <input key={'hidden_true_' + userId} type='hidden'
                  name={'group[users][' + userId + ']'} value={true} />
            )
          }
          <h3 className="title-l mbs">{t('group_edit_member')}</h3>
          <table className='ui-rights-group'>
            <thead>
              <tr>
                <td className='ui-rights-user-title' style={{borderColor: '#f3f3f3'}}>
                  {t('group_edit_person')}
                </td>
              </tr>
            </thead>
            <tbody>
              {
                f.map(
                  @state.data.userIdList,
                  (userId) =>
                    user = @state.data.users[userId]
                    <MemberRow key={'row_' + userId} user={user} onRemove={@_onRemove}
                      disabled={@state.data.userIdList.length <= 1}/>
                )
              }
            </tbody>
          </table>

          {
            if AutoComplete
              <div className='ui-add-subject ptx row' style={zIndex: '1000'}>
                <div className='col1of3'>
                  <AutoComplete className='multi-select-input'
                    name={'group[user][login][]'}
                    resourceType={'Users'}
                    onSelect={@_onSelect} />
                </div>
              </div>
          }
        </div>

        {
          if false
            # Delete link with confirm modal. Not used anymore, but I am sure it will come back one day.
            <div className="ui-form-group rowed">
              {t('group_edit_at_least_one_member_pre')}
              <a onClick={@_onDelete}>{t('group_edit_at_least_one_member_delete')}</a>
              {t('group_edit_at_least_one_member_post')}
            </div>
        }

        {
          if !f.includes(@state.data.userIdList, get.current_user_id)
            <div className="form-head">
              <div className="ui-alerts">
                <div className="ui-alert warning">
                  {t('group_edit_hint_remove_yourself')}
                </div>
              </div>
            </div>
        }

        <div className="ui-actions phl pbl mtl">
          <a href={get.cancel_url} className="link weak">{t('group_edit_cancel')}</a>
          <button type='submit' className="primary-button large">{t('group_edit_save')}</button>
        </div>

      </RailsForm>
    </div>

Link = React.createClass
  render: ({onClick, disabled, enabledClasses} = @props) ->
    if disabled == true
      <span className={classnames(enabledClasses, {disabled: true})} />
    else
      <a onClick={onClick} className={enabledClasses} />


MemberRow = React.createClass

  _onRemove: () ->
    if not @props.disabled
      @props.onRemove(@props.user.id)

  render: ({user} = @props) ->
    Elm = if @props.disabled then 'span' else 'a'

    <tr>
      <td className='ui-rights-user' style={{borderColor: '#f3f3f3'}}>
        <Link disabled={@props.disabled} onClick={@_onRemove}
          enabledClasses={'button small ui-rights-remove icon-close small'} />
        <span className='text'>
          {user.name}
        </span>
      </td>
    </tr>
