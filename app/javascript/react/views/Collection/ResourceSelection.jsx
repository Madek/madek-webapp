/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const t = require('../../../lib/i18n-translate.js')
const RailsForm = require('../../lib/forms/rails-form.jsx')
const FormButton = require('../../ui-components/FormButton.jsx')
const Modal = require('../../ui-components/Modal.jsx')

module.exports = React.createClass({
  displayName: 'Collection.ResourceSelection',
  propTypes: {
    type: React.PropTypes.oneOf(['checkbox', 'radio'])
  },

  getInitialState() {
    return { active: false }
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { authToken, get, type } = param
    return (
      <Modal widthInPixel="800">
        <RailsForm
          name="resource_meta_data"
          action={get.submit_url}
          method="put"
          authToken={authToken}>
          <div className="ui-modal-head">
            <a
              href={get.cancel_url}
              aria-hidden="true"
              className="ui-modal-close"
              data-dismiss="modal"
              title="Close"
              type="button"
              style={{ position: 'static', float: 'right', paddingTop: '5px' }}>
              <i className="icon-close" />
            </a>
            <h3 className="title-l">{get.i18n.title}</h3>
          </div>
          <div className="ui-modal-body" style={{ maxHeight: 'none' }}>
            <div className="ui-resources-table">
              <div className="ui-resources-table">
                {f.isEmpty(get.child_presenters.resources) ? (
                  <h3 className="by-center title-m">{t('collection_edit_highlights_empty')}</h3>
                ) : (
                  <table className="block">
                    <thead>
                      <tr>
                        <td className="ui-resources-table-selection">{get.i18n.h_selection}</td>
                        <td title="Titel">
                          <span className="ui-resources-table-cell-content">
                            {get.i18n.h_title}
                          </span>
                        </td>
                        <td title="Untertitel">
                          <span className="ui-resources-table-cell-content">
                            {get.i18n.h_subtitle}
                          </span>
                        </td>
                        <td title="Autor/in">
                          <span className="ui-resources-table-cell-content">
                            {get.i18n.h_author}
                          </span>
                        </td>
                        <td title="Datierung">
                          <span className="ui-resources-table-cell-content">{get.i18n.h_date}</span>
                        </td>
                        <td title="Schlagworte">
                          <span className="ui-resources-table-cell-content">
                            {get.i18n.h_keywords}
                          </span>
                        </td>
                        <td title="Rechteinhaber">
                          <span className="ui-resources-table-cell-content">
                            {get.i18n.h_responsible}
                          </span>
                        </td>
                      </tr>
                    </thead>
                    <tbody>
                      {f.map(get.child_presenters.resources, function(resource) {
                        const checked = get.uuid_to_checked_hash[resource.uuid]

                        return (
                          <tr key={resource.uuid}>
                            <td className="ui-resources-table-selection">
                              {type === 'checkbox' ? (
                                <label>
                                  <input
                                    type="hidden"
                                    name="resource_selections[][id]"
                                    value={resource.uuid}
                                  />
                                  <input
                                    type="hidden"
                                    name="resource_selections[][type]"
                                    value={resource.type}
                                  />
                                  <input
                                    className="ui-set-list-input"
                                    type="checkbox"
                                    name="resource_selections[][selected]"
                                    value="true"
                                    defaultChecked={checked}
                                  />
                                  <img className="ui-thumbnail micro" src={resource.image_url} />
                                </label>
                              ) : type === 'radio' ? (
                                <label>
                                  <input
                                    defaultChecked={checked}
                                    name="selected_resource"
                                    type="radio"
                                    value={resource.uuid}
                                  />
                                  <img className="ui-thumbnail micro" src={resource.image_url} />
                                </label>
                              ) : null}
                            </td>
                            <td data-name="title" title="">
                              <span className="ui-resources-table-cell-content">
                                {resource.title}
                              </span>
                            </td>
                            <td data-name="subtitle" title="">
                              <span className="ui-resources-table-cell-content">
                                {resource.subtitle}
                              </span>
                            </td>
                            <td data-name="author" title="">
                              <span className="ui-resources-table-cell-content">
                                {resource.authors_pretty}
                              </span>
                            </td>
                            <td data-name="portrayed object dates" title="null">
                              {resource.portrayed_object_date_pretty}
                            </td>
                            <td data-name="keywords" title="">
                              <span className="ui-resources-table-cell-content">
                                {resource.keywords_pretty}
                              </span>
                            </td>
                            <td data-name="copyright notice" title="">
                              <span className="ui-resources-table-cell-content">
                                {resource.copyright_notice_pretty}
                              </span>
                            </td>
                          </tr>
                        )
                      })}
                    </tbody>
                  </table>
                )}
              </div>
            </div>
          </div>
          <div className="ui-modal-footer">
            <div className="ui-actions">
              <a
                href={get.cancel_url}
                aria-hidden="true"
                className="link weak"
                data-dismiss="modal">
                {get.i18n.cancel}
              </a>
              {!f.isEmpty(get.child_presenters.resources) ? (
                <FormButton text={get.i18n.save} />
              ) : (
                undefined
              )}
            </div>
          </div>
        </RailsForm>
      </Modal>
    )
  }
})
