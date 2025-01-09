/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react')
const ReactDOM = require('react-dom')
const ampersandReactMixin = require('ampersand-react-mixin')
const f = require('active-lodash')
const async = require('async')
const t = require('../../../lib/i18n-translate.js')
const { ActionsBar, Button, Link } = require('../../ui-components/index.js')
const MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
const SuperBoxUpload = require('../../decorators/SuperBoxUpload.jsx')
const parseUrl = require('url').parse

let FileDrop = <div /> // client-side only
const UPLOAD_CONCURRENCY = 4

// api see <https://www.npmjs.com/package/async#queue>
const UploadQueue = async.queue(
  (resource, callback) => resource.upload(callback),
  UPLOAD_CONCURRENCY
)

module.exports = React.createClass({
  displayName: 'Uploader',
  propTypes: {
    get: React.PropTypes.shape({
      next_step: React.PropTypes.shape({
        label: React.PropTypes.string.isRequired,
        url: React.PropTypes.string.isRequired
      }).isRequired
    }).isRequired
  },

  getInitialState() {
    return {
      isClient: false,
      customUrlsAlreadyMoved: false,
      duplicatorConfiguration: f.get(this.props, 'get.duplicator_defaults')
    }
  },

  componentDidMount() {
    FileDrop = require('react-file-drop')
    if (!f.get(this.props, 'appCollection.isCollection')) {
      throw new Error('No AppCollection given!')
    }
    this.setState({ isClient: true, uploading: false, uploads: UploadQueue })

    // listen to events from UploadQueue:
    UploadQueue.drain = () => {
      if (this.isMounted()) {
        return this.setState({ uploading: false })
      }
    }
    return (UploadQueue.saturated = () => {
      if (this.isMounted()) {
        return this.setState({ waiting: true })
      }
    })
  },

  onFilesDrop(files, event) {
    return this.addFiles(files)
  },
  onFilesSelect(event) {
    this.addFiles(f.get(event, 'target.files'))

    // Ensure the event is fired again if selecting the same file again.
    // http://stackoverflow.com/questions/12030686/html-input-file-selection-event-not-firing-upon-selecting-the-same-file
    return (event.target.value = null)
  },

  addFiles(files) {
    if (!f.present(files)) {
      return
    }

    const parsedUrl = parseUrl(window.location.href, true)
    const workflowId = f.get(parsedUrl, 'query.workflow_id')
    const copyMdFromId = f.get(this.props, 'get.copy_md_from.uuid')
    const copyMdFrom = copyMdFromId
      ? {
          id: copyMdFromId,
          configuration: this.state.duplicatorConfiguration
        }
      : undefined

    if (
      (this.state.duplicatorConfiguration != null
        ? this.state.duplicatorConfiguration.move_custom_urls
        : undefined) === true
    ) {
      const configuration = f.assign({}, this.state.duplicatorConfiguration)
      configuration.move_custom_urls = false
      this.setState({
        customUrlsAlreadyMoved: true,
        duplicatorConfiguration: configuration
      })
    }

    const added = this.props.appCollection.add(
      f.map(files, file => ({ uploading: { file, workflowId, copyMdFrom } }))
    )

    // immediately trigger upload!
    this.setState({ uploading: true })
    return f.each(added, model =>
      UploadQueue.push(model, function(err, res) {
        if (err) {
          return console.error('Uploader failed!', model, err)
        }
      })
    )
  },

  isChecked(name) {
    return f.get(this.state, ['duplicatorConfiguration', name], false)
  },

  onCheckboxToggle(e) {
    const configKey = e.target.name
    const { checked } = e.target
    const configuration = f.assign({}, this.state.duplicatorConfiguration)
    configuration[configKey] = checked
    return this.setState({ duplicatorConfiguration: configuration })
  },

  renderCheckbox(name, props) {
    return (
      <input
        type="checkbox"
        name={name}
        checked={this.isChecked(name)}
        onChange={this.onCheckboxToggle}
        disabled={f.get(props, 'disabled', this.state.uploading)}
      />
    )
  },

  render(param) {
    if (param == null) {
      param = this
    }
    const { props, state } = param
    const name = 'media_entry'
    if (!state.isClient) {
      return null
    }

    return (
      <div id="ui-uploader">
        {props.get.copy_md_from ? (
          <div
            className="notice mtm pam"
            style={{
              border: '1px solid #ffeeba',
              backgroundColor: '#fff3cd',
              color: '#856404',
              borderRadius: '3px'
            }}>
            {t('media_entry_duplicator_desc_pre')}{' '}
            <Link href={props.get.copy_md_from.url} className="block">
              {props.get.copy_md_from.title}
            </Link>{' '}
            {t('media_entry_duplicator_desc_post')}
            <div id="duplicator-configuration" className="ptm">
              <span>{t('media_entry_duplicator_configuration_instructions')}</span>
              <label className="block">
                {this.renderCheckbox('copy_meta_data')}{' '}
                {t('media_entry_duplicator_configuration_copy_meta_data')}
              </label>
              <label className="block">
                {this.renderCheckbox('copy_permissions')}{' '}
                {t('media_entry_duplicator_configuration_copy_permissions')}
              </label>
              <label className="block">
                {this.renderCheckbox('copy_relations')}{' '}
                {t('media_entry_duplicator_configuration_copy_relations')}
              </label>
              <label className="block">
                {this.renderCheckbox('annotate_as_new_version_of')}{' '}
                {t('media_entry_duplicator_configuration_annotate_as_new_version_of_pre')}{' '}
                <Link href={props.get.copy_md_from.url} className="block">
                  {props.get.copy_md_from.title}
                </Link>{' '}
                {t('media_entry_duplicator_configuration_annotate_as_new_version_of_post')}
              </label>
              <label className="block">
                {this.renderCheckbox('move_custom_urls', {
                  disabled:
                    !f.get(this.props, 'get.copy_md_from.custom_urls?', false) ||
                    this.state.customUrlsAlreadyMoved ||
                    this.state.uploading
                })}{' '}
                {!f.get(this.props, 'get.copy_md_from.custom_urls?', false) ||
                this.state.customUrlsAlreadyMoved ? (
                  <span style={{ textDecoration: 'line-through' }}>
                    {t('media_entry_duplicator_configuration_move_custom_urls')}
                  </span>
                ) : (
                  t('media_entry_duplicator_configuration_move_custom_urls')
                )}
                {this.state.customUrlsAlreadyMoved ? (
                  <span> → {t('media_entry_duplicator_custom_urls_already_moved')}</span>
                ) : (
                  undefined
                )}
              </label>
            </div>
          </div>
        ) : (
          undefined
        )}
        <FileDrop onDrop={this.onFilesDrop} targetAlwaysVisible={true}>
          <SuperBoxUpload
            ref="polybox"
            authToken={props.authToken}
            ampersandCollection={props.appCollection}>
            <div className="ui-form-group rowed by-center">
              <h3 className="title-l">
                {t('media_entry_media_import_inside') + ' '}
                <label className="primary-button" style={{ fontSize: '16px', top: '-2px' }}>
                  {t('media_entry_media_import_select_media')}
                  <input
                    type="file"
                    multiple={true}
                    style={{ display: 'none' }}
                    name={name + '[media_file][]'}
                    onChange={this.onFilesSelect}
                  />
                </label>
              </h3>
            </div>
          </SuperBoxUpload>
        </FileDrop>
        <ActionsBar>
          <Button
            mod="primary"
            mods="large"
            href={props.get.next_step.url}
            disabled={state.uploading}>
            {props.get.next_step.label}
          </Button>
        </ActionsBar>
      </div>
    )
  }
})
