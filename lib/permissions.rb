module Permissions
  extend self 

  class << self

    def authorized?(user, action, resource)

      resource = resource.media_resource if resource.class.name  != MediaResource.name

      # the old authorized accepted subjects 
      raise "authorized? can only be called with a user" if user.class != User

      if resource.owner == user
        true
      elsif action == :view && resource.perm_public_may_view 
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
      .where("permissionsets.view = false")
      .where(user: user)
      .where(media_resource: resource)
      .first
    end

    def userpermission_allows action, resource, user
        resource.class.joins(:userpermissions => :user) \
          .where("#{resource.class.table_name}.id = #{resource.id}") \
          .where("users.id = #{user.id}") \
          .where("userpermissions.may_#{action} = true")
          .first
    end

    def grouppermission_allows action, resource, user
      resource.class.joins(:grouppermissions => {:group => :users}) \
        .where("#{resource.class.table_name}.id = #{resource.id}") \
        .where("users.id = #{user.id}") \
        .where("grouppermissions.may_#{action} = true") \
        .first
    end

  end

end
