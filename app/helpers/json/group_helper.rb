module Json
  module GroupHelper

    def hash_for_group(group, with = nil)
      h = {
        type: group.type,
        id: group.id,
        name: group.name
      }
      
      if with ||= nil
        if with[:users]
          users = (group.type != "MetaDepartment" ?  group.users : [])
          # TODO call hash_for users
          h[:users] = users.map do |user|
            {
              id: user.id,
              login: user.login,
              lastname: user.person.lastname,
              firstname: user.person.firstname
            }
          end
        end
      end
      
      h
    end
    
    alias :hash_for_meta_department :hash_for_group 

  end
end
      