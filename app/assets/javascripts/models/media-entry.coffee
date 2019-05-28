f = require('active-lodash')
BrowserFile = require('global/window').File
app = require('ampersand-app')
AppResource = require('./shared/app-resource.coffee')
Permissions = require('./media-entry/permissions.coffee')
Person = require('./person.coffee')
# MediaResources = require('./shared/media-resources.coffee')
t = require('../lib/i18n-translate')
getMediaType = require('./shared/get-media-type.js')
MetaData = require('./meta-data.coffee')
ResourceWithRelations = require('./concerns/resource-with-relations.coffee')
# ResourceWithListMetadata = require('./concerns/resource-with-list-metadata.coffee')
Favoritable = require('./concerns/resource-favoritable.coffee')
Deletable = require('./concerns/resource-deletable.coffee')

module.exports = AppResource.extend(
  ResourceWithRelations,
  Favoritable,
  Deletable
  # ,
  # ResourceWithListMetadata,
  {
  type: 'MediaEntry'
  urlRoot: '/entries'
  # NOTE: this allows some session-like props on presenters for simplicity:
  extraProperties: 'allow'
  props:
    title:
      type: 'string'
      required: true
    description: ['string']
    'published?':
      type: 'boolean'
      default: false
      required: true
    copyright_notice: ['string']
    portrayed_object_date: ['string']
    image_url:
      type: 'string'
      required: false
    privacy_status:
      type: 'string'
      required: true
      default: 'private'
    keywords: ['array']
    more_data: ['object']
    media_file: ['object'] # TODO: type: MediaFile

  children:
    permissions: Permissions
    responsible: Person

  collections:
    meta_data: MetaData

  session:
    uploading: 'object'

  derived:

    # mediaType either from (media_file) presenter or uploading file:
    mediaType:
      deps: ['media_file', 'uploading']
      fn: ()->
        contentType = f.presence(f.get(@media_file, 'content_type')) \
          or f.presence(f.get(@uploading, 'file.type'))
        getMediaType(contentType)

    # NOTE: we don't allow batch-editing of "currently invalid" entries
    isBatchEditable:
      deps: ['editable', 'invalid_meta_data']
      fn: ()-> @editable and !@invalid_meta_data

    uploadStatus:
      deps: ['uploading']
      fn: ()->
        if not @uploading then return
        filename = f.get(this, 'uploading.file.name')
        state = switch
          when @uploading.error
            t('media_entry_media_import_box_upload_status_error')
          when not @uploading.progress
            t('media_entry_media_import_box_upload_status_waiting')
          when @uploading.progress < 100
            t('media_entry_media_import_box_upload_status_progress_a') +
            "#{@uploading.progress.toFixed(2)}" +
            t('media_entry_media_import_box_upload_status_progress_b')
          else
            t('media_entry_media_import_box_upload_status_processing')
        return [filename, state]

  upload: (callback)->
    unless (@uploading.file instanceof BrowserFile)
      throw new Error 'Model: MediaEntry: #upload called but no file!'

    formData = new FormData()
    formData.append('media_entry[media_file]', @uploading.file)
    formData.append('media_entry[workflow_id]', @uploading.workflowId) if @uploading.workflowId

    @merge('uploading', started: (new Date()).getTime())

    # listen to progress if supported by XHR:
    handleOnProgress = ({loaded, total} = event)=>
      unless f.all([loaded, total], f.isNumber)
        return console.error('Math error!')
      @merge('uploading', progress: (loaded/total*100))

    req = @_runRequest {
      method: 'POST'
      url: app.config.relativeUrlRoot + '/entries/'
      body: formData
      beforeSend: (xhrObject) ->
        xhrObject.upload.onprogress = handleOnProgress
      },
      (err, res)=>
        # handle error
        if err or not res or res.statusCode >= 400
          error = (err or res.body or true)
          @set('uploading', f.merge(@uploading, {error: error}))
        else # or update self with server response:
          attrs = (try JSON.parse(res.body))
          @set(attrs) if attrs
          @unset('uploading')

        # pass through to callback if given:
        callback(error || null, res) if f.isFunction(callback)
})
