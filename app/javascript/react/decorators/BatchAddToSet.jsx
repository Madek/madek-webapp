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
import t from '../../lib/i18n-translate.js'
import SelectCollectionDialog from '../views/Collection/SelectCollectionDialog.jsx'
import Button from '../ui-components/Button.jsx'
import RailsForm from '../lib/forms/rails-form.jsx'
import Preloader from '../ui-components/Preloader.jsx'
import qs from 'qs'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import xhr from 'xhr'

module.exports = createReactClass({
  displayName: 'BatchAddToSet',

  getInitialState() {
    return {
      mounted: false,
      searchTerm: '',
      searching: false,
      newSets: [],
      results: []
    }
  },

  lastRequest: null,
  sendTimeoutRef: null,

  componentWillMount() {
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

      const data = {
        resource_id: this.props.get.resource_ids,
        search_term: this.state.searchTerm,
        return_to: this.state.get.return_to
      }

      const body = qs.stringify(data, {
        arrayFormat: 'brackets' // NOTE: Do it like rails.
      })

      return (this.lastRequest = xhr(
        {
          url: this.props.get.batch_select_add_to_set_url,
          method: 'POST',
          body,
          headers: {
            Accept: 'application/json',
            'Content-type': 'application/x-www-form-urlencoded',
            'X-CSRF-Token': getRailsCSRFToken()
          }
        },
        (err, res, json) => {
          if (err || res.statusCode !== 200) {
            return
          } else {
            if (this.isMounted()) {
              return this.setState({ get: JSON.parse(json), searching: false })
            }
          }
        }
      ))
    }, 500))
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
    const { authToken } = param
    const { get } = this.state

    const buttonMargins = {
      marginTop: '5px',
      marginRight: '5px'
    }

    const hasNew = this.state.newSets.length > 0
    const hasResultEntries = get.search_results.collections.length > 0 // get.collection_rows.length isnt 0

    const _search = (
      <div className="ui-search">
        <RailsForm
          ref="form"
          name="search_collections"
          action={this.props.get.batch_select_add_to_set_url}
          method="post"
          authToken={authToken}
          className="dummy">
          <input type="hidden" name="return_to" value={this.state.get.return_to} />
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
          {f.map(this.props.get.resource_ids, resource_id => [
            <input
              key={`resource_id_${resource_id.uuid}`}
              type="hidden"
              name="resource_id[][uuid]"
              value={resource_id.uuid}
            />,
            <input
              key={`resource_id_${resource_id.type}`}
              type="hidden"
              name="resource_id[][type]"
              value={resource_id.type}
            />
          ])}
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
          <input type="hidden" name="return_to" value={this.state.get.return_to} />
          {f.map(this.props.get.resource_ids, resource_id => [
            <input
              key={`resource_id_${resource_id.uuid}`}
              type="hidden"
              name="resource_id[][uuid]"
              value={resource_id.uuid}
            />,
            <input
              key={`resource_id_${resource_id.type}`}
              type="hidden"
              name="resource_id[][type]"
              value={resource_id.type}
            />
          ])}
          {hasNew
            ? f.map(this.state.newSets, (row, index) => (
                <li
                  style={{ paddingLeft: '60px', paddingRight: '200px' }}
                  key={`new_${index}`}
                  className="ui-set-list-item">
                  <img
                    style={{ margin: '0px', position: 'absolute', left: '10px', top: '10px' }}
                    className="ui-thumbnail micro"
                    src={null}
                  />
                  <span className="title">{row}</span>
                  <span className="owner">New</span>
                  <Button
                    style={{ position: 'absolute', right: '0px', top: '10px' }}
                    className="primary-button"
                    type="submit"
                    value={row}
                    name="parent_collection_id[new]">{`\
Neues Set erstellen und Einträge hinzufügen\
`}</Button>
                </li>
              ))
            : undefined}
          {(() => {
            if (this.state.searching) {
              return <Preloader style={{ marginTop: '20px' }} />
            } else if (hasResultEntries) {
              return f.map(get.search_results.collections, collection => (
                <li
                  style={{ paddingLeft: '60px', paddingRight: '200px' }}
                  key={collection.uuid}
                  className="ui-set-list-item">
                  <img
                    style={{ margin: '0px', position: 'absolute', left: '10px', top: '10px' }}
                    className="ui-thumbnail micro"
                    src={collection.image_url}
                  />
                  <span className="title">{collection.title}</span>
                  <span className="owner">{collection.responsible.name}</span>
                  <span className="created-at">{collection.created_at_pretty}</span>
                  <Button
                    style={{ position: 'absolute', right: '0px', top: '10px' }}
                    className="primary-button"
                    type="submit"
                    value={collection.uuid}
                    name="parent_collection_id[existing]">{`\
Zu diesem hinzufügen\
`}</Button>
                </li>
              ))
            }
          })()}
        </ol>
      )
    }

    if (!this.state.searching && hasResultEntries && get.search_results.has_more) {
      _content.push(
        <h3 key="content3" className="by-center title-m">
          {t('resource_select_collection_has_more')}
        </h3>
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
          {t('batch_add_to_collection_hint')}
        </h3>
      )
    }

    return (
      <SelectCollectionDialog
        onCancel={this.props.onClose}
        cancelUrl={this.state.get.return_to}
        title={
          t('batch_add_to_collection_pre') +
          this.props.get.batch_count +
          t('batch_add_to_collection_post')
        }
        toolbar={_search}
        action={get.batch_add_to_set_url}
        authToken={authToken}
        content={_content}
        method="put"
        showSave={false}
        showAddToClipboard={false}
      />
    )
  }
})
