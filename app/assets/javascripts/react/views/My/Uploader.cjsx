React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
async = require('async')
t = require('../../../lib/string-translation')('de')
FileDropBox = require('../../lib/file-dropbox.cjsx')
{ActionsBar, Button} = require('../../ui-components/index.coffee')
MediaResourcesBox = require('../../decorators/MediaResourcesBox.cjsx')

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
    unless f.get(@props, 'appCollection.isCollection')
      throw new Error 'No AppCollection given!'
    @setState(isClient: true, uploading: false, uploads: UploadQueue)

    # listen to events from UploadQueue:
    UploadQueue.drain = ()=> @setState(uploading: false) if @isMounted()
    UploadQueue.saturated = ()=> @setState(waiting: true) if @isMounted()

  onFilesDrop: (_event, files)-> @addFiles(files)
  onFilesSelect: (event)-> @addFiles(f.get(event, 'target.files'))

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

    boxGet =
      resources: props.appCollection,
      with_actions: true

    # spacer div so that the empty box has same height as with first thumbnails
    spacerDiv = <div style={height: '250px'}/>

    <div id='ui-uploader'>
      <FileDropBox onFilesDrop={@onFilesDrop}>

        <MediaResourcesBox
          ref='polybox'
          className='ui-uploader-uploads'
          mods='rounded mvl'
          authToken={props.authToken}
          fetchRelations={false}
          withBox={true}
          heading={props.appCollection.length + ' Upload(s)'}
          fallback={spacerDiv}
          get={boxGet}>

            <div className='ui-form-group rowed by-center'>
              <h3 className='title-l'>
                {t('media_entry_media_import_inside') + ' '}

                {# NOTE: wrapping in <label> means we can hide the unstylable input…}
                <label className="primary-button" style={{fontSize: '16px', top: '-2px'}}>
                  Medien auswählen
                  <input
                    type='file' multiple
                    style={{'display': 'none'}}
                    name={name + '[media_file][]'}
                    onChange={@onFilesSelect}/>
                </label>

              </h3>
            </div>
        </MediaResourcesBox>

      </FileDropBox>

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
