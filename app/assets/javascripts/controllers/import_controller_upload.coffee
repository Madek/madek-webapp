###

Upload through plupload

###

ImportController = {} unless ImportController?
class ImportController.Upload

  constructor: (options)->
    @dropboxData = if options.dropboxData? then options.dropboxData else {}
    @dropboxFiles = if options.dropboxFiles? then options.dropboxFiles else []
    @dropboxSyncInterval = undefined
    @dropboxSyncIntervalTimer = options.dropboxSyncIntervalTimer
    @maxFileSize = options.maxFileSize
    @mediaEntryIncompletes = options.mediaEntryIncompletes
    @nextStepUrl = options.nextStepUrl
    @pluploadFilesUploaded = []
    @multipartParams = options.multipartParams
    do @initalizePlupload
    do @removeUnnecessaryElements
    @setupMEIFiles @mediaEntryIncompletes if @mediaEntryIncompletes? and @mediaEntryIncompletes.length
    do @setupDropboxSync
    do @delegateEvents
    do @validateState
    window.ui-alert = (msg)-> #prevent plupload error message

  delegateEvents: ->
    @uploaderEl.bind "UploadProgress", (uploader, file) => do @setCustomProgress
    @uploaderEl.bind "UploadComplete", @onUploadComplete
    @uploaderEl.bind "FilesAdded", @addFile
    @uploaderEl.bind "FilesRemoved", (uploader, files) => do @validateState
    @uploaderEl.bind "QueueChanged", @onQueueChange
    @uploaderEl.bind "FileUploaded", (uploader, file, response) => @pluploadFilesUploaded.push {file: file, media_entry_incomplete: JSON.parse(response.response).media_entry_incomplete}
    @uploaderEl.bind "error", @onError
    $(".delete_plupload_entry").live "click", @deletePluploadFile
    $(document).on "click", "#import-start.disabled", (e)-> e.preventDefault(); return false
    $(document).on "click", "#import-start:not(.disabled)", (e)=> 
      if @anyLinesForImport() 
        do e.preventDefault
        do @startImport
    $(document).on "click", ".delete_mei", @deleteMEI
    $(document).on "click", ".open_dropbox_dialog", => @openDropboxDialog(false)
    $(document).on "click", ".delete_dropbox_file", @deleteDropboxFile

  openDropboxDialog: (errorMsg)=>
    @template = App.render "import/upload/dropbox_dialog",
      dropbox_info: @dropboxData.dropbox_info
      dropbox_exists: @dropboxData.dropbox_exists
      errorMsg: errorMsg
    App.modal @template
    @template.find("#create-dropbox").bind "click", (e)=>
      container = $(e.currentTarget).closest ".ui-modal-toolbar"
      container.html '<div class="ui-preloader small"></div>'
      $.ajax
        url: "/import/dropbox"
        type: "POST"
        success: (response)=>
          @dropboxData.dropbox_info = response
          @dropboxData.dropbox_exists = true
          container.html App.render "import/upload/dropbox_infos", @dropboxData.dropbox_info
          do @setupDropboxSync

  validateState: =>
    window.setTimeout =>
      # If files are in the uploader filelist
      if $(".plupload_content li:not(.plupload_done):visible").length > 0
        do @enableStartButton unless $(".plupload_uploading:visible").length > 0
      else
        do @disableStartButton unless $(".plupload_content li:visible").length > 0

      # If Dropbox has files enable plupload start and mark as "dropbox enabled"
      if $("#dropbox_filelist li:visible").length > 0
        $("#upload_navigation .plupload_start").addClass "dropbox_enabled"
      else
        $("#upload_navigation .plupload_start").removeClass "dropbox_enabled"

      # everything is transfered
      if $(".plupload_content li:not(.plupload_done):visible").length == 0 and $(".plupload_content li:visible").length > 0 and @trasferWasStarted
        do @finishTransfer

      # show/hide call2action depending if there is anything in the filelist or not
      if $(".plupload_content li:visible").length > 0
        $("#call2action").hide()
      else
        $("#call2action").show()
    , 200

  anyLinesForImport: -> !! $(".plupload_content li:not(.plupload_done):visible").length

  finishTransfer: ->
    window.location = @nextStepUrl if @nextStepUrl?

  enableStartButton: ->
    button = $("#import-start")
    button.removeClass "disabled"

  disableStartButton: ->
    button = $("#import-start")
    button.addClass "disabled"

  setupDropboxSync: ->
    return false if @dropboxData.dropbox_exists is false
    @setupDropboxFiles @dropboxFiles if @dropboxFiles.length > 0
    # load dropbox files with an interval
    @dropboxSyncInterval = window.setInterval =>
      $.ajax
        url: "/import.json"
        success: (response) =>
          if @dropboxFiles.length != response.length
            @setupDropboxFiles response
          @dropboxFiles = response
    , @dropboxSyncIntervalTimer

  setupDropboxFiles: (files)->
    $("#uploader #uploader_filelist").after $("<ul id='dropbox_filelist'></ul>") unless $("#uploader #dropbox_filelist").length
    $("#uploader #dropbox_filelist").html App.render "import/upload/dropbox_file", files
    do @validateState

  initalizePlupload: ->
    $("#uploader").pluploadQueue
      runtimes: 'html5'
      url: "/import.js"
      max_file_size: @maxFileSize
      dragdrop: true
      drop_element: "plupload_content"
      multipart_params: @multipartParams
      preinit :
        Init: (up, info)->
          $("#uploader").find(".plupload_content").attr("id", "plupload_content")
    @uploaderEl = $("#uploader").pluploadQueue()

  removeUnnecessaryElements: -> $("#uploader_container").removeAttr("title")

  setCustomProgress: ->
    window.setTimeout ->
      amount_not_transfered = $("#uploader_filelist li:not(.plupload_done):visible").length + $("#dropbox_filelist li:not(.plupload_done):visible").length
      amount_transfered = $("#uploader li.plupload_done").length
      amount_total = $("#uploader li:visible").length
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
    do @validateState
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
    do @validateState

  onQueueChange: (uploader)=>
    window.setTimeout =>
      for element in $("#uploader_filelist li")
        @preventPluploadDelete $(element)
        @addDeleteToPlupload $(element)
    , 200

  showTransferProgress: ->
    $(".plupload_filelist_footer .plupload_buttons .plupload_button").addClass "disabled"
    $(".plupload_filelist_footer .plupload_file_name").show()
    $(".plupload_filelist_footer .plupload_upload_status").show()
    $(".plupload_filelist_footer .plupload_upload_status").html(plupload.translate("Uploaded %d/%d files").replace(/%d/g, "0"))
    $(".plupload_filelist_footer .plupload_progress").show()

  hide_transfer_progress: ->
    $(".plupload_filelist_footer .plupload_buttons .plupload_button").removeClass "disabled"
    $(".plupload_filelist_footer .plupload_file_name").show()
    $(".plupload_filelist_footer .plupload_upload_status").hide()
    $(".plupload_filelist_footer .plupload_upload_status").html(plupload.translate("Uploaded %d/%d files").replace(/%d/g, "0"))
    $(".plupload_filelist_footer .plupload_progress").hide()

  startDropboxTransfer: ->
    clearInterval @dropboxSyncInterval
    do @showTransferProgress
    $("#uploader #dropbox_filelist").html App.render "import/upload/dropbox_file", @dropboxFiles, {status: "50%"}
    do @setCustomProgress
    $.ajax
      url: "/import/dropbox.json"
      type: "PUT"
      success: =>
        $("#uploader #dropbox_filelist").html App.render "import/upload/dropbox_file", @dropboxFiles, {status: "100%", finished: true}
        do @setCustomProgress
        do @validateState

  setupMEIFiles: (files)->
    # if ui-container is gone create the ui-container again
    if $("#uploader #mei_filelist").length == 0
      $("#uploader #uploader_filelist").after $("<ul id='mei_filelist'></ul>")
    for file in files # create lines
      $("#uploader #mei_filelist").prepend App.render "import/upload/media_entry_incomplete", file
    $("#uploader #mei_filelist").show()

  onError: (uploader, error) =>
    if error.code == -600
      openDropboxDialog(error.message)
    else
      Dialog.add
        trigger: $("#uploader_browse")
        content: $.tmpl("tmpl/upload/error", {errormsg:error.message})
        dialogClass: "plupload_error"
        closeOnEscape: true

  deleteMEI: (e)=>
    element = $(e.currentTarget)
    data = element.tmplItem().data
    line = element.closest("li")
    return false if !confirm("Sind Sie sicher dass Sie die Datei " + data.filename + " löschen möchten?")
    line.remove()
    mri = new App.MediaEntryIncomplete data
    mri.delete => do @validateState

  deleteDropboxFile: (e)=>
    element = $(e.currentTarget)
    data = element.tmplItem().data
    line = element.closest("li")
    return false if !confirm("Sind Sie sicher dass Sie die Datei " + data.filename + " löschen möchten?")
    line.remove()
    $.ajax
      url: "/import.json"
      success: =>
        do @validateState
      type: "DELETE"
      data:
        dropbox_file:
          data

  deletePluploadFile: (e)=>
    el = $(e.currentTarget)
    line = el.closest("li")
    if line.hasClass("plupload_done")
      filename = if (line.tmplItem().data.filename == undefined) then line.find(".plupload_file_name span").html() else line.tmplItem().data.filename
      return false if !confirm("Sind Sie sicher dass Sie die Datei " + filename + " löschen möchten?")
      for element in @pluploadFilesUploaded
        if line.attr("id") == element.file.id
          delete_mei_file el, element.media_entry_incomplete
          @uploaderEl.splice(line.index(), 1)
    else
      @uploaderEl.splice(line.index(), 1)

  startImport: =>
    @trasferWasStarted = true
    $(".delete_plupload_entry").remove()
    $(".delete_mei").removeClass "delete_mei"
    $(".delete_dropbox_file").removeClass "delete_dropbox_file"
    do @startDropboxTransfer if $(".plupload_dropbox.plupload_transfer").length
    $(".plupload .plupload_buttons .plupload_start").trigger("click")
    do @disableStartButton

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.Upload = ImportController.Upload