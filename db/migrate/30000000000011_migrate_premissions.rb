class MigratePremissions < ActiveRecord::Migration

  def set_new_from_old permission_holder, permission
    permission.actions.each do |old_action,action_value|
      permission_holder.send "#{Constants::Actions.old2new old_action}=", action_value
    end
    permission_holder.save!
  end

  def up


    Permission.all.each do |p| 

      if (not p.subject) and (not p.media_resource) 
        # system default, don't care about this
      elsif (not p.subject)  # public permission
        set_new_from_old p.media_resource, p
      else # the regular case
        permission_holder = 
          if p.subject.class  == User
            Userpermission.create user: p.subject, media_resource: p.media_resource
          elsif p.subject.class == Group
            Grouppermission.create group: p.subject, media_resource: p.media_resource
          else
            raise "this should never happen"
          end
        set_new_from_old permission_holder, p
      end
    end


  end

  def down
  end
end
