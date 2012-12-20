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

  toString: ->
    name = ""
    if @is_group
      name = "#{@firstname} [Gruppe]"
    else
      name = []
      name.push @firstname if @firstname? and @firstname.length
      name.push @lastname if @lastname? and @lastname.length
      name = name.join(", ")
      if @pseudonym? and @pseudonym.length
        name = [name, "(#{@pseudonym})"] 
        name = name.join(" ")
    return name

  @fetch: (query, callback)->
    $.ajax
      url: "/people.json"
      data:
        query: query
      success: (response)->
        people = _.map response, (person) -> new Person person
        callback people, response if callback?

window.App.Person = Person