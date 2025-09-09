import React from 'react'
import PropTypes from 'prop-types'
import f from 'active-lodash'
import async from 'async'
import t from '../../../lib/i18n-translate.js'
import { ActionsBar, Button, Link } from '../../ui-components/index.js'
import SuperBoxUpload from '../../decorators/SuperBoxUpload.jsx'
import { parse as parseUrl } from 'url'

let FileDrop = <div /> // client-side only
const UPLOAD_CONCURRENCY = 4

// api see <https://www.npmjs.com/package/async#queue>
const UploadQueue = async.queue(
  (resource, callback) => resource.upload(callback),
  UPLOAD_CONCURRENCY
)

class Uploader extends React.Component {
  static propTypes = {
    get: PropTypes.shape({
      next_step: PropTypes.shape({
        label: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      }).isRequired
    }).isRequired
  }

  constructor(props) {
    super(props)
    this.state = {
      isClient: false,
      customUrlsAlreadyMoved: false,
      duplicatorConfiguration: f.get(this.props, 'get.duplicator_defaults'),
      uploadError: [],
      uploading: false
    }

    this.onFilesDrop = this.onFilesDrop.bind(this)
    this.onFilesSelect = this.onFilesSelect.bind(this)
    this.addFiles = this.addFiles.bind(this)
    this.isChecked = this.isChecked.bind(this)
    this.onCheckboxToggle = this.onCheckboxToggle.bind(this)
  }

  componentDidMount() {
    FileDrop = require('react-file-drop').FileDrop
    if (!f.get(this.props, 'appCollection.isCollection')) {
      throw new Error('No AppCollection given!')
    }
    this.setState({ isClient: true, uploading: false, uploads: UploadQueue })

    // Set up event listeners for UploadQueue
    UploadQueue.drain = () => {
      this.setState({ uploading: false })
    }
    UploadQueue.saturated = () => {
      this.setState({ waiting: true })
    }
  }

  checkFiles(files) {
    const fileArray = !Array.isArray(files) && files.length ? Array.from(files) : files

    this.setState({ uploadError: [] })

    let validFiles = []

    fileArray.forEach((file, index) => {
      if (
        file.type.includes('image/jpeg') ||
        file.type.includes('image/png') ||
        file.type.includes('image/webp') ||
        file.type.includes('image/bmp') ||
        file.type.includes('image/svg+xml') ||
        file.type.includes('image/gif')
      ) {
        const img = new Image()

        img.onload = () => {
          if (img.width > 16000 || img.height > 16000) {
            this.setState(prev => ({
              uploadError: [
                ...prev.uploadError,
                `${file.name} ${t('media_entry_media_import_upload_error')}`
              ]
            }))
            fileArray.splice(index, 1)
          }

          if (img.width < 16000 && img.height < 16000) {
            validFiles.push(file)
          }

          if (validFiles.length && validFiles.length === fileArray.length) {
            // Proceed with the following code only if all files are valid
            this.addFiles(validFiles)
          }
        }

        img.src = URL.createObjectURL(file)
      } else {
        // If the file is not an image, add it to the validFiles array
        validFiles.push(file)
        if (validFiles.length && validFiles.length === fileArray.length) {
          // Proceed with the following code only if all files are valid
          this.addFiles(validFiles)
        }
      }
    })
  }

  onFilesDrop(files) {
    this.checkFiles(files)
  }

  onFilesSelect(event) {
    this.checkFiles(event.target.files)

    event.target.value = null
  }

  addFiles(files) {
    if (!Array.isArray(files) || !files.length) {
      return
    }

    const parsedUrl = parseUrl(window.location.href, true)
    const workflowId = parsedUrl.query.workflow_id
    const copyMdFromId = this.props.get.copy_md_from ? this.props.get.copy_md_from.uuid : null

    const copyMdFrom = copyMdFromId
      ? {
          id: copyMdFromId,
          configuration: this.state.duplicatorConfiguration
        }
      : undefined

    if (
      this.state.duplicatorConfiguration !== null &&
      this.state.duplicatorConfiguration.move_custom_urls === true
    ) {
      const configuration = f.assign({}, this.state.duplicatorConfiguration)
      configuration.move_custom_urls = false

      this.setState({
        customUrlsAlreadyMoved: true,
        duplicatorConfiguration: configuration
      })
    }

    const added = this.props.appCollection.add(
      files.map(file => ({ uploading: { file, workflowId, copyMdFrom } }))
    )

    this.setState({ uploading: true })

    return added.map(model =>
      UploadQueue.push(model, err => {
        if (err) {
          return console.error('Uploader failed!', model, err)
        }
      })
    )
  }

  isChecked(name) {
    return f.get(this.state, ['duplicatorConfiguration', name], false)
  }

  onCheckboxToggle(e) {
    const configKey = e.target.name
    const { checked } = e.target
    const configuration = f.assign({}, this.state.duplicatorConfiguration)
    configuration[configKey] = checked
    this.setState({ duplicatorConfiguration: configuration })
  }

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
  }

  render() {
    const { props, state } = this
    const name = 'media_entry'
    if (!state.isClient) {
      return null
    }

    return (
      <div>
        {this.state.uploadError.length > 0 ? (
          <div className="ui-alert error">
            {this.state.uploadError.map((error, index) => (
              <div key={index}>{error}</div>
            ))}
          </div>
        ) : undefined}
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
                  ) : undefined}
                </label>
              </div>
            </div>
          ) : undefined}
          <FileDrop onDrop={this.onFilesDrop} targetAlwaysVisible={true}>
            <SuperBoxUpload
              ref={el => (this.polybox = el)}
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
      </div>
    )
  }
}

module.exports = Uploader
