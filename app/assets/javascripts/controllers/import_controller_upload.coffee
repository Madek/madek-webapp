###

Upload through plupload

###

ImportController = {} unless ImportController?
class ImportController.Upload

  constructor: (options)->
    @dropboxExists = options.dropboxExists
    @dropboxFiles = options.dropboxFiles
    @dropboxInfo = options.dropboxInfo
    @dropboxSyncInterval = undefined
    @dropboxSyncIntervalTimer = options.dropboxSyncIntervalTimer
    @maxFileSize = options.maxFileSize
    @mediaEntryIncompletes = options.mediaEntriesIncomplete
    @pluploadFilesUploaded = []
    do @initalizePlupload
    @remove_not_needed_plupload_elements()
    @setupMEIFiles @mediaEntryIncompletes if @mediaEntryIncompletes?
    @setup_dropbox_sync()
    @setup_dropbox_transfer_trigger()
    do @delegateEvents
    do @validateButtons
    @setup_open_dropbox_dialog()
    @setup_delete_mei()
    @setup_delete_dropbox_file()
    @setup_delete_plupload_file()
    @setup_start_button()
    window.ui-alert = (msg)-> #prevent plupload error message

  delegateEvents: ->
    @uploaderEl.bind "UploadProgress", (uploader, file) => do @setCustomProgress
    @uploaderEl.bind "UploadComplete", @onUploadComplete
    @uploaderEl.bind "FilesAdded", @addFile
    @uploaderEl.bind "FilesRemoved", (uploader, files) => do @validateButtons
    @uploaderEl.bind "QueueChanged", @onQueueChange
    @uploaderEl.bind "StateChanged", @onStateChange
    @uploaderEl.bind "FileUploaded", (uploader, file, response) => @pluploadFilesUploaded.push {file: file, media_entry_incomplete: JSON.parse(response.response).media_entry_incomplete}
    @uploaderEl.bind "error", @onError

  setup_open_dropbox_dialog: ->
    $(".open_dropbox_dialog").live "click", ->
      open_dropbox_dialog(false)
    $("#create_dropbox").live "ajax:beforeSend", ->
      $(this).html("Dropbox wird erstellt")
      $(this).append $.tmpl("tmpl/loading_img")
      $(this).bind "click", (event) ->
        event.stopImmediatePropagation()
        event.preventDefault()
    $("#create_dropbox").live "ajax:success", (event, response, settings)->
      @dropboxInfo = response
      @dropboxExists = true
      $("#no_ftp").hide()
      $("#ftp_existing").show()
      $(".dialog").closest(".ui-dialog").css("height", "auto")
      setup_dropbox_sync()

  open_dropbox_dialog: (error)->
    content = if !error then $.tmpl("tmpl/upload/dropbox_info") else $.tmpl("tmpl/upload/dropbox_info", {error:error})
    trigger = if !error then $(".open_dropbox_dialog") else $(".plupload_add")

    Dialog.add {
      trigger: trigger
      content: content
      dialogClass: "dropbox_info"
      closeOnEscape: true
    }

  validateButtons: =>
    window.setTimeout =>
      # If files are in the uploader filelist
      if $(".plupload_content li:not(.plupload_done):visible").length > 0
        do @enableStartButton
      else
        do @disableStartButton

      # If Dropbox has files enable plupload start and mark as "dropbox enabled"
      if $("#dropbox_filelist li:visible").length > 0
        $("#upload_navigation .plupload_start").addClass "dropbox_enabled"
      else
        $("#upload_navigation .plupload_start").removeClass "dropbox_enabled"

      # Everything is transfered so show continue button
      if $(".plupload_content li:not(.plupload_done):visible").length == 0 and $(".plupload_content li:visible").length > 0
        enable_continue_button()
        show_continue_button()
        hide_start_button()
      else
        do @disableContinueButton
        do @hideContinueButton
        do @showStartButton

      # show/hide call2action depending if there is anything in the filelist or not
      if $(".plupload_content li:visible").length > 0
        $("#call2action").hide()
      else
        $("#call2action").show()

    , 200

  enable_continue_button: ->
    button = $("#upload_navigation .next")
    button.removeClass("disabled")
    button.attr("href", button.data("link_when_enabled"))

  disableContinueButton: ->
    button = $("#upload_navigation .next")
    button.addClass("disabled")
    button.attr("href", "javascript:void(0)")

  show_continue_button: ->
    button = $("#upload_navigation .next")
    button.show()

  hideContinueButton: ->
    button = $("#upload_navigation .next")
    button.hide()

  enableStartButton: ->
    button = $("#upload_navigation .plupload_start")
    button.removeClass("plupload_disabled")

  disableStartButton: ->
    button = $("#upload_navigation .plupload_start")
    button.addClass("plupload_disabled")

  showStartButton: ->
    button = $("#upload_navigation .plupload_start")
    button.show()

  hide_start_button: ->
    button = $("#upload_navigation .plupload_start")
    button.hide()

  setup_dropbox_sync: ->
    return false if @dropboxExists is false
    setup_dopbox_files @dropboxFiles if @dropboxFiles.length > 0
    # load dropbox files with an interval
    @dropboxSyncInterval = window.setInterval ->
      $.ajax({
        url: "/import"
        success: (data, status, response) ->
          if JSON.stringify(@dropboxFiles) != JSON.stringify(data)
            setup_dopbox_files data
          @dropboxFiles = data
        type: "GET"
        data: format:"json"
      })
    , @dropboxSyncIntervalTimer

  setup_dropbox_transfer_trigger: ->
    $(".plupload_start").live "click", (e)->
      if $(e.currentTarget).hasClass("dropbox_enabled")
        start_dropbox_transfer()

  setup_dopbox_files: (files)->
    # if ui-container is gone create the ui-container again
    if $("#uploader #dropbox_filelist").length == 0
      $("#uploader #uploader_filelist").after $("<ul id='dropbox_filelist'></ul>")
    # add files
    for file in files
      setup_dropbox_file file
    # remove files that where deleted
    for dropbox_element in $("#uploader #dropbox_filelist li")
      file_exists = false
      for file in files
        if $(dropbox_element).tmplItem().data.dirname == file.dirname and $(dropbox_element).tmplItem().data.filename == file.filename
          file_exists = true
      if not file_exists
        $(dropbox_element).remove()
    do @validateButtons

  setup_dropbox_file: (file)->
    # if file list-element is not already exisiting create
    already_existing = false
    for dropbox_element in $("#uploader #dropbox_filelist li")
      if $(dropbox_element).tmplItem().data.dirname == file.dirname and $(dropbox_element).tmplItem().data.filename == file.filename
        already_existing = true
    if not already_existing
      template = $.tmpl("tmpl/upload/dropbox_file", file)
      $("#uploader #dropbox_filelist").prepend template
    do @validateButtons

  initalizePlupload: ->
    $("#uploader").pluploadQueue
      runtimes: 'html5'
      url: "/import.js"
      max_file_size: @maxFileSize
      dragdrop: true
      drop_element: "plupload_content"
      multipart_params:
        '#{request_forgery_protection_token}': '#{form_authenticity_token}',
        '#{request.session_options[:key]}': '#{request.session_options[:id]}'
      preinit :
        Init: (up, info)->
          $("#uploader").find(".plupload_content").attr("id", "plupload_content")
    @uploaderEl = $("#uploader").pluploadQueue()

  remove_not_needed_plupload_elements: ->
    $("#uploader_ui-container").removeAttr("title")

  setCustomProgress: ->
    window.setTimeout ->
      amount_not_transfered = $("#uploader_filelist li:not(.plupload_done):visible").length + $("#dropbox_filelist li:not(.plupload_done):visible").length
      amount_transfered = $("#uploader_filelist li.plupload_done").length + $("#dropbox_filelist li.plupload_done").length
      amount_total =  $("#uploader_filelist li:visible").length + $("#dropbox_filelist li:visible").length
      # customize progress status text
      upload_status_text = $("#uploader .plupload_upload_status").html().replace(/\d+\/\d+/, (amount_total-amount_not_transfered)+"/"+amount_total)
      $("#uploader .plupload_upload_status").html(upload_status_text)
      # customize progress bar
      progress_bar_width = 100-(amount_not_transfered/amount_total*100)
      $("#uploader .plupload_progress_bar").width(progress_bar_width+"%")
    , 200

  addFile: (uploader, files)=>  
    for file in files
      if file.size == 0
        uploader.removeFile file
        Dialog.add
          trigger: $("#uploader_browse")
          content: $.tmpl("tmpl/upload/zero_bytes_error", {filename:file.name})
          dialogClass: "zero_bytes_error"
          closeOnEscape: true
    do @validateButtons
    window.setTimeout =>
      for element in $("#uploader_filelist li.plupload_delete")
        @preventPluploadDelete $(element)
        @addDeleteToPlupload $(element)
    , 200

  addDeleteToPlupload: (element) ->
    if $(element).find(".delete_plupload_entry").length == 0
      $(element).find(".plupload_file_action").append("<span class='delete_plupload_entry'></span>")

  preventPluploadDelete: (element) =>
    cloned_action = $(element).find(".plupload_file_action a").clone()
    $(element).find(".plupload_file_action a").remove()
    $(element).find(".plupload_file_action").prepend cloned_action
    $(element).addClass("plupload_transfer").removeClass("plupload_delete")

  onUploadComplete: (uploader) =>
    do @setCustomProgress
    do $("#uploader .plupload_progress").show
    do @validateButtons

  onQueueChange: (uploader)=>
    window.setTimeout =>
      for element in $("#uploader_filelist li")
        @preventPluploadDelete $(element)
        @addDeleteToPlupload $(element)
    , 200

  onStateChange: (uploader)=>
    if uploader.state == plupload.STOPPED
      window.setTimeout ->
        for element in $("#uploader_filelist li")
          @addDeleteToPlupload $(element)
      , 200

  validate_progress_bar: ->
    if $(".plupload_content li:visible").length == 0
      hide_transfer_progress()

  show_transfer_progress: ->
    $(".plupload_filelist_footer .plupload_buttons").hide()
    $(".plupload_filelist_footer .plupload_file_name").show()
    $(".plupload_filelist_footer .plupload_upload_status").show()
    $(".plupload_filelist_footer .plupload_upload_status").html(plupload.translate("Uploaded %d/%d files").replace(/%d/g, "0"))
    $(".plupload_filelist_footer .plupload_progress").show()

  hide_transfer_progress: ->
    $(".plupload_filelist_footer .plupload_buttons").show()
    $(".plupload_filelist_footer .plupload_file_name").show()
    $(".plupload_filelist_footer .plupload_upload_status").hide()
    $(".plupload_filelist_footer .plupload_upload_status").html(plupload.translate("Uploaded %d/%d files").replace(/%d/g, "0"))
    $(".plupload_filelist_footer .plupload_progress").hide()

  start_dropbox_transfer: ->
    clearInterval @dropboxSyncInterval
    finish_transfer() if $("#dropbox_filelist li").length is 0
    show_transfer_progress()
    # begin transfer each file seperately
    for dropbox_file in @dropboxFiles
      # mark file as transfer in progress
      $("#dropbox_filelist li").each (i_element, element) ->
        if($(element).tmplItem().data.dirname == dropbox_file.dirname && $(element).tmplItem().data.filename == dropbox_file.filename)
          $(element).removeClass("plupload_delete").addClass("plupload_uploading")
          $(element).find(".plupload_file_status").html("50%")
      # transfer dropbox file
      $.ajax {
        url: "/import"
        success: (data, status, request) ->
          do @setCustomProgress
          do @validateButtons
          $("#dropbox_filelist li").each (i_element, element) ->
            if($(element).tmplItem().data.dirname == data.dropbox_file.dirname && $(element).tmplItem().data.filename == data.dropbox_file.filename)
              $(element).data("media_entry_incomplete", data.media_entry_incomplete)
              $(element).removeClass("plupload_uploading plupload_transfer").addClass("plupload_done")
              $(element).find(".plupload_file_status").html("100%")
              $(element).find(".plupload_file_action").show()
        error: (request, status, error) ->
          console.log("ERROR")
        type: "POST"
        data:
          format:"json"
          dropbox_file:
            dirname: dropbox_file.dirname
            filename: dropbox_file.filename
      }

  finish_transfer: ->
    enable_continue_button()

  setupMEIFiles: (files)->
    # if ui-container is gone create the ui-container again
    if $("#uploader #mei_filelist").length == 0
      $("#uploader #uploader_filelist").after $("<ul id='mei_filelist'></ul>")

    # add files
    for file in files
      setup_media_entry_incomplete_file file

  setup_media_entry_incomplete_file: (file)->
    template = $.tmpl("tmpl/upload/mei_file", file)
    $("#uploader #mei_filelist").prepend template

  onError: (uploader, error) =>
    if error.code == -600
      open_dropbox_dialog(error.message)
    else
      Dialog.add
        trigger: $("#uploader_browse")
        content: $.tmpl("tmpl/upload/error", {errormsg:error.message})
        dialogClass: "plupload_error"
        closeOnEscape: true

  setup_delete_mei: ->
    $(".delete_mei").live "click", (event)->
      # prevent normal link behaviour
      event.preventDefault()
      return false
    $(".delete_mei:not(.deleting)").live "click", (event)->
      return false if !confirm("Sind Sie sicher dass Sie die Datei " + $(this).closest("li").tmplItem().data.filename + " löschen möchten?")
      delete_mei_file $(this), $(this).tmplItem().data

  delete_mei_file: (element, data)->
    $(element).addClass "deleting"
    $.ajax {
      url: "/import"
      success: (data, status, request) ->
        element.removeClass("deleting")
        element.closest("li").remove()
        do @validateButtons
        validate_progress_bar()
      error: (request, status, error) ->
        console.log("ERROR")
      type: "DELETE"
      data:
        format:"json"
        media_entry_incomplete:
          data
    }

  setup_delete_dropbox_file: ->
    $(".delete_dropbox_file").live "click", (event)->
      # prevent normal link behaviour
      event.preventDefault()
      return false
    $(".delete_dropbox_file:not(.deleting)").live "click", (event)->
      return false if !confirm("Sind Sie sicher dass Sie die Datei " + $(this).closest("li").tmplItem().data.filename + " löschen möchten?")
      if $(this).closest("li").data("media_entry_incomplete")
        delete_mei_file $(this), $(this).closest("li").data("media_entry_incomplete")
      else
        delete_dropbox_file $(this), $(this).tmplItem().data

  delete_dropbox_file: (element, data)->
    $(element).addClass "deleting"
    $.ajax
      url: "/import"
      success: (data, status, request) ->
        element.removeClass("deleting")
        element.closest("li").remove()
        do @validateButtons
        validate_progress_bar()
      error: (request, status, error) ->
        console.log("ERROR")
      type: "DELETE"
      data:
        format:"json"
        dropbox_file:
          data

  setup_delete_plupload_file: ->
    $(".delete_plupload_entry").live "click", (event)->
      if $(this).closest("li").hasClass("plupload_done")
        filename = if ($(this).closest("li").tmplItem().data.filename == undefined) then $(this).closest("li").find(".plupload_file_name span").html() else $(this).closest("li").tmplItem().data.filename
        return false if !confirm("Sind Sie sicher dass Sie die Datei " + filename + " löschen möchten?")
        for element in @pluploadFilesUploaded
          if $(this).closest("li").attr("id") == element.file.id
            delete_mei_file $(this), element.media_entry_incomplete
            @uploaderEl.splice($(this).closest("li").index(), 1)
      else
        @uploaderEl.splice($(this).closest("li").index(), 1)

  setup_start_button: ->
    $("#upload_navigation .plupload_start").bind "click", ()->
      if $(this).is(":not(.plupload_disabled)")
        $(".plupload .plupload_buttons .plupload_start").trigger("click")
        hide_start_button()
        show_continue_button()

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.Upload = ImportController.Upload