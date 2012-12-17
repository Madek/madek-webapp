###

PDF PREVIEW CONTROLLER

For media entry preview, controlling the pdf preview

###

class PdfPreviewController

  el: ".ui-document-preview-container"
  currentPage: 1

  constructor: (data)->
    @el = $(@el)
    PDFJS.workerSrc = data.worker_path
    @document_path = data.document_path
    @canvas = @el.find("#ui-document-preview")[0]
    @controls = @el.find(".ui-document-preview-controls")
    @nextButton = @controls.find(".ui-document-preview-next")
    @prevButton = @controls.find(".ui-document-preview-prev")
    do @delegateEvents
    do @fetchDocument

  delegateEvents: ->
    @nextButton.on "click", => do @nextPage
    @prevButton.on "click", => do @prevPage

  fetchDocument: ->
    PDFJS.getDocument(@document_path).then (pdf) => 
      @pdf = pdf
      do @enableNext if @pdf.numPages > 1
      do @renderPage

  enablePrev: -> @prevButton.show()
  disablePrev: -> @prevButton.hide()

  prevPage: ->
    return true if @currentPage == 1
    do @decreaseCurrentPage
    do @renderPage

  enableNext: -> @nextButton.show()
  disableNext: -> @nextButton.hide()

  nextPage: ->
    return true if @currentPage == @pdf.numPages
    do @increaseCurrentPage
    do @renderPage

  decreaseCurrentPage: ->
    @currentPage--
    do @checkControls

  increaseCurrentPage: ->
    @currentPage++
    do @checkControls

  checkControls: ->
    if @currentPage == @pdf.numPages
      do @disableNext
    else
      do @enableNext
    if @currentPage == 1
      do @disablePrev 
    else
      do @enablePrev

  renderPage: ->
    @pdf.getPage(@currentPage).then (page) =>
      scale = 1.5
      viewport = page.getViewport(scale)

      canvas = @canvas
      context = canvas.getContext("2d")
      canvas.height = viewport.height
      canvas.width = viewport.width

      renderContext =
        canvasContext: context
        viewport: viewport

      page.render renderContext

window.App.PdfPreviewController = PdfPreviewController


  
  