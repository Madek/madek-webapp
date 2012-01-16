module Permissions
  extend self 

  class << self

    def authorized?(user, action, resource)

      # the old authorized accepted subjects 
      raise "authorized? can only be called with a user" if user.class != User

      if resource.user == user
        true
      elsif resource.permissionset.send(action) == true
        true
      elsif userpermission_disallows action, resource, user
        false
      elsif userpermission_allows action, resource, user
        true
      elsif grouppermission_allows action, resource, user
        true
      else
        false
      end

    end

    def is_private? user, resource, action
      new_action = Constants::Actions.old2new action
      nil == (user.viewable_media_resources.where("#{new_action}able_media_resources_users.user_id <> #{user.id}").first)
    end


    ### private

    def userpermission_disallows action, resource, user
      Userpermission.joins(:permissionset)
      .where("permissionsets.#{action} = false")
      .where(user_id: user.id)
      .where(media_resource_id: resource.id)
      .first
    end

    def userpermission_allows action, resource, user
      Userpermission.joins(:permissionset)
      .where("permissionsets.#{action} = true")
      .where(user_id: user.id)
      .where(media_resource_id: resource.id)
      .first
    end

    def grouppermission_allows action, resource, user
      Grouppermission.joins(:permissionset,:group => :users)
        .where(media_resource_id: resource.id)
        .where("permissionsets.#{action} = true")
        .where("groups_users.user_id = #{user.id}")
        .first
    end

  end

end
