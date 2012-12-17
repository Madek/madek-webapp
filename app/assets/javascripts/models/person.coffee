class Person

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  validate: ->
    @errors = []
    if !@firstname? and !@lastname? and !@pseudonym?
      @errors.push {text: "Mindestens eine Angabe ist Pflicht"}
    if @errors.length then false else true

  create: (callback)->
    $.ajax
      url: "/people.json"
      type: "POST"
      data:
        person:
          firstname: @firstname
          lastname: @lastname
          pseudonym: @pseudonym
          is_group: @is_group
      success: (data)=>
        for k,v of data
          @[k] = v
        callback(data) if callback?

window.App.Person = Person