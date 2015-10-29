React = require('react')
ReactDOM = require('react-dom')
ampersandReactMixin = require('ampersand-react-mixin')
f = require('active-lodash')
async = require('async')
t = require('../lib/string-translation.coffee')('de')
FileDropBox = require('./lib/file-dropbox.cjsx')
MediaResourcesBox = require('./decorators/MediaResourcesBox.cjsx')

UPLOAD_CONCURRENCY = 4

# api see <https://www.npmjs.com/package/async#queue>
UploadQueue = async.queue(((resource, callback)->
  resource.upload(callback)
), UPLOAD_CONCURRENCY)

module.exports = React.createClass
  displayName: 'Uploader'
  # PropTypes:
  #   appCollection: <Model>

  getInitialState: ()-> {active: false}
  componentDidMount: ()->
    unless @props.appCollection.isCollection
      throw new Error 'No AppCollection given!'
    @setState(active: true)

  onFilesDrop: (_event, files)-> @addFiles(files)
  onFilesSelect: (event)-> @addFiles(f.get(event, 'target.files'))

  addFiles: (files)->
    return unless f.present(files)

    added = @props.appCollection.add f.map files, (file)->
      {uploading: {file: file}}

    # immediately trigger upload!
    # TODO: toggle to turn it of and start upload manually?
    # TODO: shorten
    f.each added, (model)-> UploadQueue.push(model)

  render: ({props, state} = @)->
    name = 'media_entry'

    <div id='ui-uploader'>
      <FileDropBox onFilesDrop={@onFilesDrop}>
        {# TMP: this is the static fallback, just re-use it for now}
        <label className='ui-form-group rowed by-center'>
          <div className='form-label'>
            <h3 className='title-l'>{t('media_entry_media_import_inside')}</h3>
          </div>

          <div className='form-item'>
            <div className='ui-container mas pal'>
              <input onChange={@onFilesSelect} type='file' multiple name={name + '[media_file][]'}/>
            </div>
          </div>

        </label>
      </FileDropBox>

      {if state.active
        <div className='ui-container bordered midtone rounded mvl phl ptl'
          id='ui-resources-preview'>
          <MediaResourcesBox
            className='ui-uploader-uploads'
            list={props.appCollection}/>
        </div>
      }
    </div>
