React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
async = require('async')
t = require('../../../lib/i18n-translate.js')
{ActionsBar, Button} = require('../../ui-components/index.coffee')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')
SuperBoxUpload = require('../../decorators/SuperBoxUpload.jsx')

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
      next_url: React.PropTypes.string.isRequired
    }).isRequired

  getInitialState: ()->
    isClient: false

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

    added = @props.appCollection.add f.map files, (file)->
      {uploading: {file: file}}

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

  render: ({props, state} = @)->
    name = 'media_entry'
    return null unless state.isClient

    <div id='ui-uploader'>
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
          href={props.get.next_url}
          disabled={state.uploading}>
          {t('media_entry_media_import_gotodrafts')}
        </Button>
      </ActionsBar>

    </div>
