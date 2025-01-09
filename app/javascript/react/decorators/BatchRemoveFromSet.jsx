/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const f = require('active-lodash')
const t = require('../../lib/i18n-translate.js')
const PageContent = require('../views/PageContent.cjsx')
const TabContent = require('../views/TabContent.cjsx')
const Tabs = require('../views/Tabs.cjsx')
const Tab = require('../views/Tab.cjsx')
const batchDiff = require('../../lib/batch-diff.js')
const BatchHintBox = require('./BatchHintBox.cjsx')

const Button = require('../ui-components/Button.cjsx')
const Icon = require('../ui-components/Icon.cjsx')
const RailsForm = require('../lib/forms/rails-form.cjsx')
const formXhr = require('../../lib/form-xhr.js')
const setUrlParams = require('../../lib/set-params-for-url.js')
const Preloader = require('../ui-components/Preloader.cjsx')
const FormButton = require('../ui-components/FormButton.cjsx')

module.exports = React.createClass({
  displayName: 'BatchRemoveFromSet',

  _onCancel(event) {
    if (this.props.onCancel) {
      event.preventDefault()
      this.props.onCancel()
      return false
    } else {
      return true
    }
  },

  _requestUrl() {
    return setUrlParams(this.props.get.batch_remove_from_set_url, {
      resource_id: this.props.get.resource_ids,
      return_to: this.props.get.return_to,
      parent_collection_id: this.props.get.parent_collection_id
    })
  },

  getInitialState() {
    return {
      mounted: false
    }
  },

  componentWillMount() {
    return this.setState({ get: this.props.get })
  },

  componentDidMount() {
    return this.setState({ mounted: true })
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get, authToken } = param
    return (
      <RailsForm
        name="resource_meta_data"
        action={this._requestUrl()}
        method="patch"
        authToken={authToken}>
        <input type="hidden" name="return_to" value={this.props.get.return_to} />
        <input
          type="hidden"
          name="parent_collection_id"
          value={this.props.get.parent_collection_id}
        />
        <div className="ui-modal-head">
          <a
            href={get.return_to}
            aria-hidden="true"
            className="ui-modal-close"
            data-dismiss="modal"
            title="Close"
            type="button"
            style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
            <i className="icon-close" />
          </a>
          <h3 className="title-l">{t('batch_remove_from_collection_title')}</h3>
        </div>
        <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
          <p className="pam by-center">
            {t('batch_remove_from_collection_question_part_1')}
            <strong>{get.media_entries_count}</strong>
            {t('batch_remove_from_collection_question_part_2')}
            <strong>{get.collections_count}</strong>
            {t('batch_remove_from_collection_question_part_3')}
          </p>
        </div>
        <div className="ui-modal-footer">
          <div className="ui-actions">
            <a href={get.return_to} aria-hidden="true" className="link weak" data-dismiss="modal">
              {t('batch_remove_from_collection_cancel')}
            </a>
            <FormButton text={t('batch_remove_from_collection_remove')} />
          </div>
        </div>
      </RailsForm>
    )
  }
})
