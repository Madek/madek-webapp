window.AppAdmin ||= {}
window.AppAdmin.APIApplication ||= {}
window.AppAdmin.APIApplication.New ||= {}

window.AppAdmin.APIApplication.New.initialize= ($form)->

  do initializeUserAutocompleteInput= ->
    
    # we haven't done any requests yet…
    currentRequest= null
    
    # set up autocomplete, attach handler
    $form.find("input#api_application_user").autocomplete
      source: (request, response_handler)->
        # abort the previous request if any
        currentRequest?.abort()
        # make request and save it for later aborting
        currentRequest= search_users(request.term, response_handler)
    
    # actual function to search for users
    search_users= (search_term, callback)->
      $.ajax 
        #url: "/app_admin/users/search"  
        url: "/app_admin/users/autocomplete_search"  
        data:
          search_term: search_term
        success: (users)->
          #callback map_users_data users
          callback users

    # UNUSED:
    # # only used when we do extendedsearch
    # map_users_data= (users)-> 
    #   $.map users, (user)-> 
    #     value: "#{user.name} [#{user.login}]"


