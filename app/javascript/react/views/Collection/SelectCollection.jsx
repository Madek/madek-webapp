/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import f from 'active-lodash'
import t from '../../../lib/i18n-translate.js'
import RailsForm from '../../lib/forms/rails-form.jsx'
import formXhr from '../../../lib/form-xhr.js'
import Preloader from '../../ui-components/Preloader.jsx'
import Button from '../../ui-components/Button.jsx'
import SelectCollectionDialog from './SelectCollectionDialog.jsx'

module.exports = createReactClass({
  displayName: 'SelectCollection',

  getInitialState() {
    return {
      mounted: false,
      searchTerm: '',
      searching: false,
      newSets: [],
      get: null,
      errors: null
    }
  },

  lastRequest: null,
  sendTimeoutRef: null,

  UNSAFE_componentWillMount() {
    return this.setState({ get: this.props.get, searchTerm: this.props.get.search_term })
  },

  componentDidMount() {
    return this.setState({ mounted: true })
  },

  _onChange(event) {
    this.setState({ searchTerm: event.target.value })
    this.setState({ searching: true })

    if (this.sendTimeoutRef !== null) {
      return
    }

    return (this.sendTimeoutRef = setTimeout(() => {
      this.sendTimeoutRef = null

      if (this.lastRequest) {
        this.lastRequest.abort()
      }

      return (this.lastRequest = formXhr(
        {
          method: 'GET',
          url: this._requestUrl(),
          form: this.refs.form
        },
        (result, json) => {
          if (!this.isMounted()) {
            return
          }
          if (result === 'success') {
            return this.setState({ get: json.collection_selection, searching: false })
          }
        }
      ))
    }, 500))
  },

  _requestUrl() {
    return this.props.get.select_collection_url
  },

  _onClickNew(event) {
    event.preventDefault()

    if (this.state.searchTerm) {
      const trimmed = this.state.searchTerm.trim()
      if (trimmed.length > 0) {
        this.state.newSets.push(trimmed)
        this.setState({ newSets: this.state.newSets })
      }
    }

    return false
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    let { authToken, get } = param
    if (this.state.get) {
      ;({ get } = this.state)
    }

    const buttonMargins = {
      marginTop: '5px',
      marginRight: '5px'
    }

    const hasNew = this.state.newSets.length > 0
    const hasResultEntries = get.collection_rows.length !== 0

    const _search = (
      <div className="ui-search">
        <RailsForm
          ref="form"
          name="search_collections"
          action={get.select_collection_url}
          method="get"
          authToken={authToken}
          className="dummy">
          <input
            type="text"
            autoCorrect="off"
            autoComplete="off"
            autoFocus="autofocus"
            className="ui-search-input block"
            placeholder={t('resource_select_collection_search_placeholder')}
            name="search_term"
            value={this.state.searchTerm}
            onChange={this._onChange}
          />
          {!this.state.mounted ? (
            [
              <Button
                key="search_button"
                style={buttonMargins}
                className="button"
                type="submit"
                name="search">
                {t('resource_select_collection_search')}
              </Button>,
              <Button
                key="clear_button"
                style={buttonMargins}
                className="button"
                type="submit"
                name="clear">
                {t('resource_select_collection_clear')}
              </Button>
            ]
          ) : (
            <button onClick={this._onClickNew} className="button ui-search-button">
              Neues Set erstellen
            </button>
          )}
        </RailsForm>
      </div>
    )

    const _content = []

    if (this.state.searching && !(hasNew || hasResultEntries)) {
      _content.push(<Preloader key="content1" />)
    }

    if (hasNew || hasResultEntries) {
      _content.push(
        <ol key="content2" className="ui-set-list pbs">
          {hasNew
            ? f.map(this.state.newSets, (row, index) => (
                <li key={`new_${index}`} className="ui-set-list-item">
                  <label>
                    <input
                      type="hidden"
                      name={`new_collections[new_${index}][checked]`}
                      value="false"
                    />
                    <input type="hidden" name={`new_collections[new_${index}][name]`} value={row} />
                    <ControlledCheckbox
                      className="ui-set-list-input"
                      name={`new_collections[new_${index}][checked]`}
                      value="true"
                      checked={true}
                    />
                    <span className="title">{row}</span>
                    <span className="owner">{get.current_user.label}</span>
                    <span className="created-at">{t('resource_select_collection_new')}</span>
                  </label>
                </li>
              ))
            : undefined}
          {(() => {
            if (this.state.searching) {
              return <Preloader style={{ marginTop: '20px' }} />
            } else if (hasResultEntries) {
              return f.map(get.collection_rows, function (row) {
                const { collection } = row
                const checked = row.contains_media_entry
                return (
                  <li key={collection.uuid} className="ui-set-list-item">
                    <label>
                      <input
                        type="hidden"
                        name={`selected_collections[${collection.uuid}][]`}
                        value="false"
                      />
                      <ControlledCheckbox
                        className="ui-set-list-input"
                        name={`selected_collections[${collection.uuid}][]`}
                        value="true"
                        checked={checked}
                      />
                      <span className="title">{collection.title}</span>
                      <span className="owner">{collection.authors_pretty}</span>
                      <span className="created-at">{collection.created_at_pretty}</span>
                    </label>
                  </li>
                )
              })
            }
          })()}
        </ol>
      )
    }

    if (!hasResultEntries && f.presence(get.search_term) && !this.state.searching) {
      _content.push(
        <h3 key="content3" className="by-center title-m">
          {t('resource_select_collection_non_found')}
        </h3>
      )
    }

    if (!hasResultEntries && !f.presence(get.search_term) && !this.state.searching) {
      _content.push(
        <h3 key="content4" className="by-center title-m">
          {t('resource_select_collection_non_assigned')}
        </h3>
      )
    }

    return (
      <SelectCollectionDialog
        onCancel={this.props.onClose}
        cancelUrl={get.resource_url}
        title={t('resource_select_collection_title')}
        toolbar={_search}
        action={get.add_remove_collection_url}
        authToken={authToken}
        content={_content}
        method="patch"
        showSave={true}
        showAddToClipboard={true}
      />
    )
  }
})

var ControlledCheckbox = createReactClass({
  displayName: 'ControlledCheckbox',

  getInitialState() {
    return {
      checked: false
    }
  },

  UNSAFE_componentWillMount() {
    return this.setState({ checked: this.props.checked })
  },

  _onChange(event) {
    return this.setState({ checked: event.target.checked })
  },

  render() {
    return (
      <input
        className={this.props.className}
        type="checkbox"
        name={this.props.name}
        value={this.props.value}
        checked={this.state.checked}
        onChange={this._onChange}
      />
    )
  }
})
