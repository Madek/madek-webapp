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
              $template.find(".image").append $.tmpl "tmpl/media_resource/thumb_box", 
                  is_set: target.data("type")=="MediaSet"
                  media_type: target.data("type")
                  image: "/media_resources/#{target.data("resource-id")}/image"
                ,
                  with_link: false
                  with_actions: false
              target.data "template", $template
              $template.data "target", target
              # prevent media set popup
              $template.delegate ".item_box .thumb_box_set", "mouseenter", (e)-> e.stopImmediatePropagation(); return false

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
          classes: 'ui-tooltip-meta_data_description popup_menu'
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
    $.ajax
      url: "/media_resources.json"
      type: 'GET'
      data: 
        ids: [id]
        with: 
          children: true
          media_type: true
          flags: true
      success: (data)=>
        mr = data.media_resources[0]
        template.find(".infos").html JST['visualization/templates/popup_menu_info'](mr)
        if mr.children? 
          template.find(".contains_info").html @template_contains
            n_media_entries: mr.children.pagination.total_media_entries
            n_media_sets: mr.children.pagination.total_media_sets

        template.find(".image").html $.tmpl "tmpl/media_resource/thumb_box", 
          $.extend true, mr,
            image: "/media_resources/#{mr.id}/image"
            without_interactions: true
        ,
          with_link: false
          with_actions: false
          interactions: false
        template.data("target").qtip("reposition")
