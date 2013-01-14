###

Native Browser Loading

This script provides functionalities for start or stop the native browser loading behaviour

###

class BrowserLoadingIndicator

  @start: =>
    unless @iframe?
      @iframe = $("<iframe style='display: none;'></iframe>")
    @iframe.appendTo $("body")
    do @iframe[0].contentDocument.open

  @stop: =>
    if @iframe? and @iframe.length
      do @iframe[0].contentDocument.close
      do @iframe.detach

window.App.BrowserLoadingIndicator = BrowserLoadingIndicator