f = require('active-lodash')
BrowserFile = require('global/window').File
AppResource = require('./shared/app-resource.coffee')
Permissions = require('./media-entry/permissions.coffee')
Person = require('./person.coffee')
# MediaResources = require('./shared/media-resources.coffee')
ResourceMetaData = require('./shared/resource-meta-data.coffee')
MetaData = require('./meta-data.coffee')
Favoritable = require('./concerns/resource-favoritable.coffee')
Deletable = require('./concerns/resource-deletable.coffee')

module.exports = AppResource.extend(
  Favoritable,
  Deletable,
  {
  type: 'MediaEntry'
  urlRoot: '/entries'
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
      required: true
    privacy_status:
      type: 'string'
      required: true
      default: 'private'
    keywords: ['array']
    more_data: ['object']

  children:
    permissions: Permissions
    responsible: Person

  collections:
    meta_data: MetaData
    # relations: MediaResources

  session:
    uploading: 'object'

  derived:
    uploadStatus:
      deps: ['uploading']
      fn: ()->
        switch
          when not @uploading then return
          when @uploading.error
            'Error!'
          when not @uploading.progress
            'Waiting…'
          when @uploading.progress < 100
            "Uploading… #{@uploading.progress.toFixed(2)}%"
          else
            'Processing…'

  upload: (callback)->
    unless (@uploading.file instanceof BrowserFile)
      throw new Error 'Model: MediaEntry: #upload called but no file!'

    formData = new FormData()
    formData.append('media_entry[media_file]', @uploading.file)

    @merge('uploading', started: (new Date()).getTime())

    req = @_runRequest {
      method: 'POST'
      url: '/entries/'
      body: formData
      },
      (err, res)=>
        # handle error
        if err or not res
          @set('uploading', {error: (err or true)})
        else # or update self with server response:
          attrs = (try JSON.parse(res.body))
          @set(attrs) if attrs
          @unset('uploading')

        # pass through to callback if given:
        callback(err, res) if f.isFunction(callback)

    # listen to progress if supported by XHR:
    if req.upload
      req.upload.onprogress = ({loaded, total} = event)=>
        unless f.all([loaded, total], f.isNumber)
          return console.error('Math error!')
        @merge('uploading', progress: (loaded/total*100))
})
