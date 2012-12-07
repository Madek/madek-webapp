class MediaSet

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  valid: ->
    errors = []
    errors.push {text: "Titel ist ein Pflichtfeld"} if not @title? or @title.length <= 0
    if errors.length then errors else undefined

  create: ->
    $.ajax
      url: "/media_sets.json"
      type: "POST"
      data:
        media_set:
          meta_data_attributes:[{meta_key_label: "title",value: @title}]
      success: (data)=>
        for k,v of data
          @[k] = v
        $(@).trigger "created"

  @fromForm: (form)->
    data = {}
    for obj in form.serializeArray()
      data[obj.name] = obj.value
    new MediaSet data

window.App.MediaSet = MediaSet