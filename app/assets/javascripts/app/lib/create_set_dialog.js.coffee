jQuery -> 
  $("body").delegate ".open_create_set_dialog", "click", (e)-> 
    do e.preventDefault
    trigger = if $(e.target).is ".open_create_set_dialog" then $(e.target) else $(e.target).closest("a")
    new CreateSetDialog trigger

class CreateSetDialog

  constructor: (trigger)->
    @trigger = trigger
    do @openDialog
    do @delegateEvents

  openDialog: =>
    @dialog = Dialog.add
      trigger: @trigger
      dialogClass: "create_set small"
      content: $.tmpl "app/views/create_set/create_set_dialog"
      closeOnEscape: false

  delegateEvents: =>
    @dialog.delegate ".actions .cancel", "click", (e)=>
      do e.preventDefault
      $(@dialog).dialog("close")
    @dialog.delegate "#create_set", "submit", (e)=>
      do e.preventDefault
      @createSet @dialog.find("form#create_set")

  createSet: (form)=>
    title = form.find("input.title").val()
    if title.length
      data = media_set:
              meta_data_attributes:[{meta_key_label: "title",value: title}]
      if form.find("input[name='as_filterset']:checked").length
        $.extend(data, {filter: $("section.media_resources.index").data("controller").filter_panel.current_filter})
      $.ajax
        url: "/media_sets.json"
        type: "POST"
        data: data
        beforeSende: =>
          button = @dialog.find("button.create")
          button.data("text", button.html())
          button.width(button.width()).html("").append $.tmpl("tmpl/loading_img")
        success: (data)->
          window.location = "/media_sets/#{data.id}"
    else
      @dialog.find(".errors").html("Bitte Titel eingeben").show()
