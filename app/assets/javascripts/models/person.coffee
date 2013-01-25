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

  toString: -> App.Person.toString @

  @toString: (person)->
    if person.is_group
      name = "#{person.firstname} [Gruppe]"
    else if person.name?
      name = person.name
    else
      name = []
      name.push person.lastname if person.lastname? and person.lastname.length
      name.push person.firstname if person.firstname? and person.firstname.length
      name = name.join(", ")
      if person.pseudonym? and person.pseudonym.length
        name = [name, "(#{person.pseudonym})"] 
        name = name.join(" ")
    name

  @fetch: (query, callback)->
    $.ajax
      url: "/people.json"
      data:
        query: query
      success: (response)->
        people = _.map response, (person) -> new Person person
        callback people, response if callback?

window.App.Person = Person