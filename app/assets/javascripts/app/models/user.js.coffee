class User

  constructor: (obj)->
    if obj?
      for k,v of obj
        @[k] = v

  is_admin: => _.any @groups, (g)-> g.name == "Admin"

window.App.User = User