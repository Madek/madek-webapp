f = require('active-lodash')
AppResource = require('./shared/app-resource.coffee')
Permissions = require('./media-entry/permissions.coffee')
Person = require('./person.coffee')
# MediaResources = require('./shared/media-resources.coffee')
ResourceMetaData = require('./shared/resource-meta-data.coffee')
MetaData = require('./meta-data.coffee')
BrowserFile = require('global/window').File

xhr = require('xhr')
getRailsCSRFToken = require('../lib/rails-csrf-token.coffee')

module.exports = AppResource.extend
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
    favored:
      type: 'boolean'
      default: false
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
          when not @uploading.progress
            'Waiting…'
          when @uploading.progress < 100
            "Uploading… #{@uploading.progress.toFixed(2)}%"
          else
            'Processing…'

  # instance methods:
  setFavoredStatus: (action, callback)->
    if !f.include(['favor', 'disfavor'], action)
      throw new Error('ArgumentError!')
    @set('favored', (if (action is 'favor') then true else false))
    runRequest(
      {method: 'PATCH', url: @url + '/' + action},
      (err, res, data)=>
        @set('favored', data.isFavored)
        callback(err, res, data))

  upload: (callback)->
    unless (@uploading.file instanceof BrowserFile)
      throw new Error 'Model: MediaEntry: #upload called but no file!'

    formData = new FormData()
    formData.append('media_entry[media_file]', @uploading.file)

    @merge('uploading', started: (new Date()).getTime())

    req = runRequest {
      method: 'POST'
      url: '/entries/'
      body: formData
      },
      (err, res)=>
        # update self with server response:
        unless err or not res
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

# ajax helper
runRequest = (req, callback)->
  return xhr({
    method: req.method
    url: req.url
    body: req.body
    headers: {
      'Accept': 'application/json'
      'X-CSRF-Token': getRailsCSRFToken()}},
    (err, res, body)->
      data = (try JSON.parse(body)) or body
      callback(err, res, data))
