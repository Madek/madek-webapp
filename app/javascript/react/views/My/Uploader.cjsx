React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
async = require('async')
t = require('../../../lib/i18n-translate.js')
{ActionsBar, Button, Link} = require('../../ui-components/index.coffee')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
SuperBoxUpload = require('../../decorators/SuperBoxUpload.jsx')
parseUrl = require('url').parse

FileDrop = <div/> # client-side only
UPLOAD_CONCURRENCY = 4

# api see <https://www.npmjs.com/package/async#queue>
UploadQueue = async.queue(((resource, callback)->
  resource.upload(callback)
), UPLOAD_CONCURRENCY)

module.exports = React.createClass
  displayName: 'Uploader'
  propTypes:
    # appCollection: TODO: <Model>
    get: React.PropTypes.shape({
      next_step: React.PropTypes.shape({
        label: React.PropTypes.string.isRequired,
        url: React.PropTypes.string.isRequired
      }).isRequired
    }).isRequired

  getInitialState: ()->
    isClient: false
    customUrlsAlreadyMoved: false
    duplicatorConfiguration: f.get(@props, 'get.duplicator_defaults')

  componentDidMount: ()->
    FileDrop = require('react-file-drop')
    unless f.get(@props, 'appCollection.isCollection')
      throw new Error 'No AppCollection given!'
    @setState(isClient: true, uploading: false, uploads: UploadQueue)

    # listen to events from UploadQueue:
    UploadQueue.drain = ()=> @setState(uploading: false) if @isMounted()
    UploadQueue.saturated = ()=> @setState(waiting: true) if @isMounted()

  onFilesDrop: (files, event)->
    @addFiles(files)
  onFilesSelect: (event)->
    @addFiles(f.get(event, 'target.files'))

    # Ensure the event is fired again if selecting the same file again.
    # http://stackoverflow.com/questions/12030686/html-input-file-selection-event-not-firing-upon-selecting-the-same-file
    event.target.value = null

  addFiles: (files)->
    return unless f.present(files)

    parsedUrl = parseUrl(window.location.href, true)
    workflowId = f.get(parsedUrl, 'query.workflow_id')
    copyMdFromId = f.get(@props, 'get.copy_md_from.uuid')
    copyMdFrom = if copyMdFromId then {
      id: copyMdFromId
      configuration: @state.duplicatorConfiguration
    }

    if @state.duplicatorConfiguration?.move_custom_urls is true
      configuration = f.assign({}, @state.duplicatorConfiguration)
      configuration.move_custom_urls = false
      @setState(
        customUrlsAlreadyMoved: true
        duplicatorConfiguration: configuration
      )

    added = @props.appCollection.add f.map files, (file)->
      {uploading: {file: file, workflowId: workflowId, copyMdFrom: copyMdFrom}}

    # TODO: enable this (needs more polishing, in miniature there is nothing to see)
    # # HACK: force miniature layout if more than 20 items:
    # if @props.appCollection.length >= 20
    #   @refs['polybox'].setLayout('miniature')

    # immediately trigger upload!
    @setState(uploading: true)
    # TODO: toggle to turn it of and start upload manually?
    f.each added, (model)->
      UploadQueue.push(
        model, (err, res)->
          console.error('Uploader failed!', model, err) if err)

  isChecked: (name) ->
    f.get(@state, ['duplicatorConfiguration', name], false)

  onCheckboxToggle: (e) ->
    configKey = e.target.name
    checked = e.target.checked
    configuration = f.assign({}, @state.duplicatorConfiguration)
    configuration[configKey] = checked
    @setState(duplicatorConfiguration: configuration)

  renderCheckbox: (name, props) ->
    <input
      type='checkbox'
      name={name}
      checked={@isChecked(name)}
      onChange={@onCheckboxToggle}
      disabled={f.get(props, 'disabled', @state.uploading)}
    />

  render: ({props, state} = @)->
    name = 'media_entry'
    return null unless state.isClient

    <div id='ui-uploader'>
      {<div className='notice mtm pam' style={{border: '1px solid #ffeeba'; backgroundColor: '#fff3cd'; color: '#856404'; borderRadius: '3px'}}>
          {t('media_entry_duplicator_desc_pre')}
          {' '}
          <Link href={props.get.copy_md_from.url} className='block'>{props.get.copy_md_from.title}</Link>
          {' '}
          {t('media_entry_duplicator_desc_post')}
        <div id='duplicator-configuration' className='ptm'>
          <span>{t('media_entry_duplicator_configuration_instructions')}</span>
          <label className='block'>
            {@renderCheckbox('copy_meta_data')} {t('media_entry_duplicator_configuration_copy_meta_data')}
          </label>
          <label className='block'>
            {@renderCheckbox('copy_permissions')} {t('media_entry_duplicator_configuration_copy_permissions')}
          </label>
          <label className='block'>
            {@renderCheckbox('copy_relations')} {t('media_entry_duplicator_configuration_copy_relations')}
          </label>
          <label className='block'>
            {@renderCheckbox('annotate_as_new_version_of')}
            {' '}
            {t('media_entry_duplicator_configuration_annotate_as_new_version_of_pre')}
            {' '}
            <Link href={props.get.copy_md_from.url} className='block'>{props.get.copy_md_from.title}</Link>
            {' '}
            {t('media_entry_duplicator_configuration_annotate_as_new_version_of_post')}
          </label>
          <label className='block'>
            {@renderCheckbox('move_custom_urls', disabled: !f.get(@props, 'get.copy_md_from.custom_urls?', false) or @state.customUrlsAlreadyMoved or @state.uploading)}
            {' '}
            {if not f.get(@props, 'get.copy_md_from.custom_urls?', false) or @state.customUrlsAlreadyMoved then <span style={{ textDecoration: 'line-through' }}>{t('media_entry_duplicator_configuration_move_custom_urls')}</span> else t('media_entry_duplicator_configuration_move_custom_urls')}
            {<span> → {t('media_entry_duplicator_custom_urls_already_moved')}</span> if @state.customUrlsAlreadyMoved}
          </label>
        </div>
      </div> if !!props.get.copy_md_from}

      <FileDrop onDrop={@onFilesDrop} targetAlwaysVisible={true}>
        <SuperBoxUpload ref='polybox' authToken={props.authToken} ampersandCollection={props.appCollection}>
          <div className='ui-form-group rowed by-center'>
            <h3 className='title-l'>
              {t('media_entry_media_import_inside') + ' '}

              {# NOTE: wrapping in <label> means we can hide the unstylable input…}
              <label className="primary-button" style={{fontSize: '16px', top: '-2px'}}>
                {t('media_entry_media_import_select_media')}
                <input
                  type='file' multiple
                  style={{'display': 'none'}}
                  name={name + '[media_file][]'}
                  onChange={@onFilesSelect}/>
              </label>
            </h3>
          </div>
        </SuperBoxUpload>
      </FileDrop>

      <ActionsBar>
        <Button
          mod='primary'
          mods='large'
          href={props.get.next_step.url}
          disabled={state.uploading}>
          {props.get.next_step.label}
        </Button>
      </ActionsBar>

    </div>
