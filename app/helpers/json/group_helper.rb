module Json
  module GroupHelper

    def hash_for_group(group, with = nil)
      h = {
        type: group.type,
        id: group.id,
        name: group.to_s
      }
      
      if with ||= nil
        if with[:users]
          users = (group.type != "MetaDepartment" ?  group.users : [])
          # TODO call hash_for users
          h[:users] = users.map do |user|
            {
              id: user.id,
              login: user.login,
              last_name: user.person.last_name,
              first_name: user.person.first_name
            }
          end
        end
      end
      
      h
    end
    
    alias :hash_for_meta_department :hash_for_group 

  end
end
      
