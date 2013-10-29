window.App ||= {}
window.App.Responsibilities = {}
window.App.Responsibilities.initialize= ($form)-> 

  initializeUserAutocompleteInput= ->
    ajax= null
    $form.find("input#user").autocomplete
      source: (request, response)->
        ajax.abort() if ajax?
        ajax = App.User.fetch request.term, (users)->
          response _.map users, (user)-> 
            id: user.id 
            name: user.name
            value: "#{user.name} [#{user.login}]"

  
  initializePermissionsSetPresets= -> 

    $("select").removeClass("hidden")

    do setPreset= ->
      userpermission_state= $(".userpermission input[id]").toArray().map((e)->$(e)).map ($iel)->
        [$iel.attr('id'), ( if $iel.prop('checked') then "true" else "false") ]

      options= $("select option").toArray().map((e)->$(e))

      filtered= options.filter ($o)->
        userpermission_state.map(([key,value])->
          $o.attr(key) == value).reduce( ((prev,curr)->
            prev and curr),true)

      if filtered[0]?
        filtered[0].prop('selected',true) 
      else
        $("option[value='custom']").prop('selected',true)
        
    $(".userpermission").change (event)->
      setPreset()


  initializeSetPermissions= ->

    $("option[value='custom']").attr("disabled",true)

    $("select").change (event)->
      option= $(event.target).find("option:selected")
      ["userpermission_view","userpermission_download","userpermission_edit","userpermission_manage"].forEach (s)->
        target_value = option.attr(s) == "true"
        $("##{s}").prop("checked",target_value)


  initializeUserAutocompleteInput()
  initializePermissionsSetPresets()
  initializeSetPermissions()

