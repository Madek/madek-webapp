module Json
  module PermissionHelper

    # TODO
    #def hash_for_permission(permission, with = nil)
    #end

    def hash_for_permission_preset(permission_preset, with = nil)
      h = {}
      [:name, :view, :download, :edit, :manage].each do |k|
        h[k] = permission_preset.send(k)
      end
      h
    end

    def hash_for_permissions_for_media_resources(media_resources, with = nil)
      h = {
        public: {},
        you: {}
      }
      
      user_actions = [:view, :edit, :download, :manage]
      group_actions = [:view, :edit, :download]
      
      # PUBLIC  
      group_actions.each do |action|
        h[:public][action] = media_resources.select(&action).map(&:id).sort
        end
       
      # YOU
      user_actions.each do |action|
        h[:you][action] = media_resources.select do |media_resource|
          current_user.authorized?(action, media_resource)
        end.map(&:id).sort
        h[:you][:name] = current_user.to_s
        h[:you][:id] = current_user.id
      end
      
      if with ||= nil
        # OWNERS
        if with[:owners] and with[:owners].to_s == "true" # OPTIMIZE boolean check
          h[:owners] = media_resources.map(&:user).uniq.map do |user|
            x = {:id => user.id, :name => user.to_s}
            x[:media_resource_ids] = media_resources.select do |media_resource|
              media_resource.user_id == user.id
            end.map(&:id).sort
            x
          end
        end
        # USERS
        if with[:users] and with[:users].to_s == "true" # OPTIMIZE boolean check
          h[:users] = media_resources.flat_map(&:userpermissions).map(&:user).uniq.map do |user|
            x = {:id => user.id, :name => user.to_s}
            user_actions.each do |action|
              x[action] = media_resources.select do |media_resource|
                !!media_resource.userpermissions.detect {|x| x.user_id == user.id and x.send(action) }
              end.map(&:id).sort
            end
            x
          end
        end
        # GROUPS
        if with[:groups] and with[:groups].to_s == "true" # OPTIMIZE boolean check
          h[:groups] = media_resources.flat_map(&:grouppermissions).map(&:group).uniq.map do |group|
            x = {:id => group.id, :name => group.to_s}
            group_actions.each do |action|
              x[action] = media_resources.select do |media_resource|
                !!media_resource.grouppermissions.detect {|x| x.group_id == group.id and x.send(action) }
              end.map(&:id).sort
            end
            x
          end
        end
      end
        
      h
    end

  end
end
      