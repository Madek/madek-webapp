module Permissions
  extend self 

  class << self

    def authorized?(user, action, resource)

      resource = resource.media_resource if resource.class.name  != MediaResource.name

      # the old authorized accepted subjects 
      raise "authorized? can only be called with a user" if user.class != User

      if resource.owner == user
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

    def userpermission_disallows action, resource, user
      Userpermission.joins(:user,:permissionset,:media_resource)
      .where("permissionsets.#{action} = false")
      .where(user_id: user.id)
      .where(media_resource_id: resource.id)
      .first
    end

    def userpermission_allows action, resource, user
      Userpermission.joins(:user,:permissionset,:media_resource)
      .where("permissionsets.#{action} = true")
      .where(user_id: user.id)
      .where(media_resource_id: resource.id)
      .first
    end

    def grouppermission_allows action, resource, user
      Grouppermission.joins(:permissionset,:media_resource,:group => :users)
        .where(media_resource_id: resource.id)
        .where("permissionsets.#{action} = true")
        .where("user.id = #{user.id}")
        .first
    end

  end

end
