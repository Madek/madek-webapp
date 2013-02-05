class Group

  constructor: (data)->
    @refreshData data

  refreshData: (data)->
    for k,v of data
      @[k] = v
    @users = _.map @users, (user)-> new App.User user

  addUser: (user)->
    @removeUser user
    @users.push user

  removeUser: (user)->
    @users = _.reject @users, (u)-> u.id is user.id

  validate: ->
    @errors = []
    @errors.push {text: "Der Name der Gruppe muss angegeben werden."} if not @name? or @name.length <= 0
    if @errors.length then false else true

  isDeletable: ->
    @deleteErrors = []
    @deleteErrors.push {text: "Gruppen mit mehr als einem Mitglied können nicht gelöscht werden."} if @users.length > 1
    if @deleteErrors.length then false else true    

  fetch: (callback)->
    $.ajax
      url: "/groups/#{@id}.json"
      success: (data)=>
        @refreshData data
        callback(data) if callback?

  create: (callback)->
    $.ajax
      url: "/groups.json"
      type: "POST"
      data:
        name: @name
      success: (data)=>
        @refreshData data
        callback(data) if callback?

  delete: (callback)->
    $.ajax
      url: "/groups/#{@id}.json"
      type: "DELETE"
      success: => do callback if callback?

  update: (callback)->
    $.ajax
      url: "/groups/#{@id}.json"
      type: "PUT"
      data: 
        name: @name
        user_ids: (_.map @users, (u)-> u.id)
      success: => do callback if callback?

  @fetch: (query, callback)->
    $.ajax
      url: "/groups.json"
      data:
        query: query
      success: (response)->
        callback response if callback?

window.App.Group = Group
