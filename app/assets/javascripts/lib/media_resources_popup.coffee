###

MediaSet Popup

This script extends the thumbnail box for loading children and/or parents

###

jQuery ->
  
  active_list = ".active.ui-resources"
  res_popup_top= [
    ".ui-thumbnail.media-entry",
    ".ui-thumbnail.media-set",
    ".ui-thumbnail.filter-set"
  ]
  res_popup_bottom= [
    ".ui-thumbnail.media-set",
    ".ui-thumbnail.filter-set"
  ]

  $(active_list)
    .find(res_popup_top.concat(res_popup_bottom).join())
    .live("hover", (e)->
      el = $(e.currentTarget).closest ".ui-resource"
      new MediaSetPopup el unless el.data("media_set_popup")?)


class MediaSetPopup

  constructor: (el)->
    @el = el
    @el.data "media_set_popup", @
    @id = @el.data "id"
    @parents_el = @el.find ".ui-thumbnail-level-up-items"
    @children_el = @el.find ".ui-thumbnail-level-down-items"
    do @load

  load: ->
    App.MediaResource.fetch
      ids: [@id]
      with:
        children:
          pagination: {per_page: 2}
          with:
            media_type: true
        parents:
          pagination: {per_page: 2}
          with:
            media_type: true
      , (mediaResources, response)=>
        if mediaResources[0]?.children?
          @children=
            resources: mediaResources[0].children.media_resources
            pagination: response?.media_resources[0]?.children?.pagination
        if mediaResources[0]?.parents?
          @parents=
            resources: mediaResources[0].parents.media_resources
            pagination: response?.media_resources[0]?.parents?.pagination
        do @render

  render: ->
    if @parents
      @parents_el.html App.render "media_resources/popup/parents", {parents: @parents}
    if @children
      @children_el.html App.render "media_resources/popup/children", {children: @children}
