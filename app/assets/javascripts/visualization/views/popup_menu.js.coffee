Visualization.Views.PopupMenu = Backbone.View.extend

  template: JST['visualization/templates/popup_menu']
  template_contains: JST['visualization/templates/popup_menu_info_contains']

  initialize: ->
    @el = $("#drawing")

  delegateEvents: ->
    @el.on "mouseenter", "circle, rect, text", (e)=>
      console.log ["mouseenter event", e]
      console.log $(e.currentTarget)
      target = $(e.currentTarget).closest(".node")
      console.log target
      console.log target.find("circle")
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
              is_mine= -> target.data("user-id") == current_user.id 
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
          effect: ->
            $(this).show()
            $(target).qtip('reposition')
        hide:
          event: "mouseleave"
          delay: 300
          fixed: true
          target: target

  getAdditionalData: (template, id)->
    App.MediaResource.fetch
      ids: [id]
      with: 
        children: true
        media_type: true
        flags: true
      , (media_resources, response)=>
        mr = media_resources[0]
        //
        template.find(".resource").html App.render "media_resources/media_resource", mr
        template.data("target").qtip("reposition")

        if mr.children? 
          template.find(".contains_info").html @template_contains
            n_media_entries: mr.totalChildEntries()
            n_media_sets: mr.totalChildSets()


