class FilterSet extends App.MediaResource

  constructor: (data)->
    super data
    for k,v of data
      @[k] = v
    @

  validate: ->
    @errors = []
    @errors.push {text: "Titel ist ein Pflichtfeld"} if not @title? or @title.length <= 0
    if @errors.length then false else true

  create: (callback)=>
    $.ajax
      url: "/filter_sets.json"
      type: "POST"
      data:
        filter_set:
          meta_data_attributes:[{meta_key_label: "title", value: @getMetaDatumByMetaKeyName("title").value}]
          settings:
            filter: @filter
      success: (data)=>
        for k,v of data
          @[k] = v
        $(@).trigger "created"
        callback(data) if callback?

  update: (callback)=>
    $.ajax
      url: "/filter_sets/#{@id}.json"
      type: "PUT"
      data:
        filter_set:
          settings:
            filter: @filter
      success: (data)=>
        for k,v of data
          @[k] = v
        $(@).trigger "updated"
        callback(data) if callback?

  @fromForm: (form)->
    metaData = _.map form.serializeArray(), (obj)=>
      name: obj.name
      value: obj.value
    new FilterSet {meta_data: metaData}

window.App.FilterSet = FilterSet
