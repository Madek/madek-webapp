class Person

  constructor: (data)->
    if data? and data.string?
      $.extend @, App.Person.firstAndLastNameFromString(data.string)
      delete data.string
    for k,v of data
      @[k] = v
    @

  validate: ->
    @errors = []
    if !@first_name? and !@last_name? and !@pseudonym?
      @errors.push {text: "Mindestens eine Angabe ist Pflicht"}
    if @errors.length then false else true

  create: (callback)->
    $.ajax
      url: "/people.json"
      type: "POST"
      data:
        person:
          first_name: @first_name
          last_name: @last_name
          pseudonym: @pseudonym
          is_group: @is_group
      success: (data)=>
        for k,v of data
          @[k] = v
        callback(data) if callback?

  toString: -> App.Person.toString @

  @toString: (person)->
    if person.is_group
      name = "#{person.first_name} [Gruppe]"
    else if person.name?
      name = person.name
    else
      name = []
      name.push person.last_name if person.last_name? and person.last_name.length
      name.push person.first_name if person.first_name? and person.first_name.length
      name = name.join(", ")
      if person.pseudonym? and person.pseudonym.length
        name = [name, "(#{person.pseudonym})"] 
        name = name.join(" ")
    name

  @firstAndLastNameFromString: (string)->
    splitted = string.split(/,\s/)
    if splitted.length == 2
      return {last_name: splitted[1], first_name: splitted[0]}
    else
      return {first_name: string}

  @nameFromString: (string)->
    splitted = string.split(/\s/)
    if splitted.length == 2 and not string.match ","
      "#{splitted[1]}, #{splitted[0]}"
    else
      string

  @fetch: (query, callback)->
    $.ajax
      url: "/people.json"
      data:
        query: query
      success: (response)->
        people = _.map response, (person) -> new Person person
        callback people, response if callback?

window.App.Person = Person
