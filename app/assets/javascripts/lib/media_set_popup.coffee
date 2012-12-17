###

MediaSet Popup

This script extends the mediaset thumb box for loading children and parents

###

jQuery => 
  active_list = ".active.ui-resources"
  media_sets = "#{active_list} .ui-thumbnail.media-set"
  filter_sets = "#{active_list} .ui-thumbnail.filter-set"
  $("#{media_sets}, #{filter_sets}").live "mouseenter", (e)=>
    el = $(e.currentTarget).closest ".ui-resource"
    new MediaSetPopup el unless el.data("media_set_popup")?

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
      , (media_resources, response)=>
        @children = media_resources[0].children.media_resources
        @childrenPagination = response.media_resources[0].children.pagination
        @parents = media_resources[0].parents.media_resources
        @parentsPagination = response.media_resources[0].parents.pagination
        do @render

  render: ->     
    @parents_el.html App.render "media_sets/popup/parents", {parents: @parents}, {pagination: @parentsPagination}
    @children_el.html App.render "media_sets/popup/children", {children: @children}, {pagination: @childrenPagination}