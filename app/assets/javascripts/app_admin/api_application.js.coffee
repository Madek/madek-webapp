window.AppAdmin ||= {}
window.AppAdmin.APIApplication ||= {}
window.AppAdmin.APIApplication.New ||= {}

window.AppAdmin.APIApplication.New.initialize= ($form)->

  initializeUserAutocompleteInput= ->

    ajax= null

    # only used when we do extendedsearch
    map_users_data= (users)-> 
      $.map users, (user)-> 
        value: "#{user.name} [#{user.login}]"


    get_users_request= (search_term,result_handler)->
      $.ajax 
        #url: "/app_admin/users/search"  
        url: "/app_admin/users/autocomplete_search"  
        data:
          search_term: search_term
        success: (users)->
          #result_handler map_users_data(users)
          result_handler users

    $form.find("input#api_application_user").autocomplete
      source: (request, response_handler)->
        ajax.abort() if ajax?
        ajax = get_users_request(request.term, response_handler)

  initializeUserAutocompleteInput()


