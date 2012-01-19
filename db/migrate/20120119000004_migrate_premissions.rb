class MigratePremissions < ActiveRecord::Migration

  def set_new_from_old permission_holder, permission

    permission.actions.each do |old_action,action_value|
      begin
        permission_holder.send "#{Constants::Actions.old2new old_action}=", action_value
      rescue 
        binding.pry
      end
    end
    permission_holder.save!
  end

  def up


    Permission.all.each do |p| 

      if (not p.subject) and (not p.media_resource) 
        # system default (false,false,false,false) don't need this
      elsif (not p.subject)  # public permission
        set_new_from_old p.media_resource, p
      else # the regular case
        permission_holder = 
          if p.subject.class  == User
            Userpermission.create user: p.subject, media_resource: p.media_resource
          elsif p.subject.class.table_name == Group.table_name
            Grouppermission.create group: p.subject, media_resource: p.media_resource
          else
            raise "this should never happen"
          end
        set_new_from_old permission_holder, p
      end
    end

    drop_table :permissions

  end


  def down
    
    raise "this migration is not revertable" 

  end

end
