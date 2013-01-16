class MediaResource

  constructor: (data)->
    for k,v of data
      @[k] = v
    @type = _.str.dasherize(@type).replace(/^-/,"") if @type?
    @meta_data = _.map(@meta_data, (md)->new App.MetaDatum md) if @meta_data?
    @title = @getMetaDatumByMetaKeyName("title").value if @getMetaDatumByMetaKeyName("title")?
    @author = @getMetaDatumByMetaKeyName("author").value if @getMetaDatumByMetaKeyName("author")?
    @is_shared = !@is_public and !@is_private if @is_private? and @is_public?
    @

  delete: ->
    $.ajax
      url: "/media_resources/#{@id}.json"
      type: "DELETE"

  favor: ->
    $.ajax
      url: "/media_resources/#{@id}/favor.json"
      type: "PUT"

  disfavor: ->
    $.ajax
      url: "/media_resources/#{@id}/disfavor.json"
      type: "PUT"

  totalChildren: -> @children.pagination.total
  totalChildEntries: -> @children.pagination.total_media_entries
  totalChildSets: -> @children.pagination.total_media_sets

  fetchOutArcs: (callback)=>
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        child_id: @id
      success: (response)=>
        @parentIds = _.map response.media_resource_arcs, (arc)-> arc.parent_id
        callback(response) if callback?

  getMetaDatumByMetaKeyName: (metaKeyName)-> new App.MetaDatum _.find @meta_data, (metaDatum)-> metaDatum.name is metaKeyName

  updateMetaDatum: (metaKeyName, value, additionalData, callback)->
    metaDatum = _.find @meta_data, (metaDatum)-> metaDatum.name is metaKeyName
    metaDatum.setValue value, additionalData if metaDatum?
    $.ajax
      url: "/media_resources/#{@id}/meta_data/#{metaKeyName}.json"
      type: "PUT"
      data:
        value: value
      success: (response)->
        callback(response) if callback?

  validateForDefinition: (metaKeyDefinition)->
    requiredKeys = _.filter metaKeyDefinition.meta_keys, (key)-> key.settings.is_required
    @valid = not _.any requiredKeys, (key)=>
      metaDatum = @getMetaDatumByMetaKeyName key.name
      not (metaDatum.value? and metaDatum.value.length)
    return @valid

  validateSingleKey: (metaKeyDefinition, metaKeyName)->
    requiredKeys = _.filter metaKeyDefinition.meta_keys, (key)-> key.settings.is_required
    requiredKey = _.find requiredKeys, (requiredKey)-> requiredKey.name == metaKeyName
    unless requiredKey?
      @valid = true
    else
      metaDatum = @getMetaDatumByMetaKeyName metaKeyName
      if (metaDatum.value? and metaDatum.value.length)
        @valid = true
      else
        @valid = false
    return @valid

  @fetch: (data, callback)=>
    $.ajax
      url: "/media_resources.json"
      data: data
      success: (response)=>
        if response.media_resources?
          media_resources = _.map response.media_resources, (mr)-> new MediaResource mr
        callback(media_resources, response) if callback?

window.App.MediaResource = MediaResource