describe "Sets Widget", ->
  
  beforeEach ->
    loadFixtures 'has_set_widget.html'
    jasmine.Ajax.useMock()
    spyOn($,"ajax").andCallFake (options) ->
      #NOTE Work in Progress
      #switch JSON.stringify(options.data)
        #when "{\"accessible_action\":\"edit\",\"with\":{\"set\":{\"creator\":1,\"created_at\":1,\"title\":1}}}"
          #options.success(SetResponse.index.data, SetResponse.index.status, SetResponse.index.request)
  
  it "automaticly sets up for all elements with a 'has-set-widget' class", ->
    SetWidget.setup()
    $(".has-set-widget").click()
