window.App.Responsibilities = {}

window.App.Responsibilities.initialize= ($form)-> 

  initializeUserAutocompleteInput= ->
    ajax= null
    #$input= $form.find("input#user")
    #$input.addClass("hidden")
    $autocompleteInput = $form.find("input#user")

    $autocompleteInput.autocomplete
      source: (request, response)->
        ajax.abort() if ajax?
        ajax = App.User.fetch request.term, (users)->
          response _.map users, (user)-> 
            id: user.id 
            name: user.name
            value: "#{user.name} [#{user.login}]"

  initializeUserAutocompleteInput()
  








  





