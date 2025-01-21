/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import BatchAddToSet from './BatchAddToSet.jsx'
import qs from 'qs'
import xhr from 'xhr'
import Modal from '../ui-components/Modal.jsx'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

module.exports = createReactClass({
  displayName: 'BatchAddToSetModal',

  getInitialState() {
    return {
      mounted: false,
      loading: true
    }
  },

  componentDidMount() {
    const data = {
      search_term: '',
      resource_id: this.props.resourceIds,
      return_to: this.props.returnTo
    }

    const body = qs.stringify(data, {
      arrayFormat: 'brackets' // NOTE: Do it like rails.
    })

    return xhr(
      {
        url: '/batch_select_add_to_set',
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
          return this.setState({
            get: JSON.parse(json),
            loading: false
          })
        }
      }
    )
  },

  render() {
    if (this.state.loading) {
      return <Modal loading={true} />
    } else {
      return (
        <Modal loading={false}>
          <BatchAddToSet
            returnTo={this.props.returnTo}
            get={this.state.get}
            async={true}
            authToken={this.props.authToken}
            onClose={this.props.onClose}
          />
        </Modal>
      )
    }
  }
})
