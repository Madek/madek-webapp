Visualization.Views.PopupMenu = Backbone.View.extend

  template: JST['visualization/templates/popup_menu']
  template_contains: JST['visualization/templates/popup_menu_info_contains']
  template_favorite: JST['visualization/templates/popup_menu_info_favorite']


  initialize: ->
    @el = $("#drawing")

  delegateEvents: ->
    @el.on "mouseenter", "circle, rect, text", (e)=>
      target = $(e.currentTarget).closest(".node")
      return true if target.attr("hasPopup") == "true"
      target.attr "hasPopup", "true"
      $(target).qtip
        position:
          target: target.find("circle")
          my: 'center right'
          at: 'center left'
          viewport: $(window)
        content:
          text: =>
            if not target.data("template")?
              $template = $ @template 
                title: target.data("title")
                id: target.data("resource-id")
                type: target.data("type")
              target.data "template", $template
              $template.data "target", target
              is_mine= -> target.data("user-id") == currentUser.id 
              is_set= -> target.data("type") == "MediaSet"

              $template.find('#link_for_descendants_of').addClass('shown') if is_set()
              $template.find('#link_for_my_component_with').addClass('shown') if is_mine()
              $template.find('#link_for_my_descendants_of').addClass('shown') if is_mine() and is_set()


              @getAdditionalData $template, target.data("resource-id")
            else
              $template = target.data "template"
            return $template
        style:
          classes: 'popup_menu popover'
          tip:
            height: 18
            width: 12
        show:
          solo: true
          delay: 250
          ready: true
        hide:
          delay: 400
          fixed: true
          target: target

  getAdditionalData: (template, id)->
    App.MediaResource.fetch
      ids: [id]
      with: 
        children: true
        is_favorite: true
        is_private: true
        is_public: true
        is_shared: true
        media_type: true
      , (media_resources, response)=>
        mr = media_resources[0]
        template.find(".resource").html App.render "media_resources/media_resource", mr

        template.find(".favorite_info").html @template_favorite
          is_favorite: mr.is_favorite

        if mr.children? 
          template.find(".contains_info").html @template_contains
            n_media_entries: mr.totalChildEntries()
            n_media_sets: mr.totalChildSets()


