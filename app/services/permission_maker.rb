class PermissionMaker
  def initialize(parent_resource, receiver, permission_params)
    @parent_resource = parent_resource
    @receiver = receiver
    @permission_params = permission_params
  end

  def call
    ActiveRecord::Base.transaction do
      add_permission_to_resource
      add_permission_to_children(:media_sets)
      add_permission_to_children(:media_entries)
    end
  end

  private

  def add_permission_to_resource(resource: nil, scope: nil)
    resource ||= @parent_resource
    permission = find_or_initialize_permission(resource)
    scope ||= @scope
    if @permission_params[scope].present?
      permission.assign_attributes(@permission_params[scope])
      permission.save!
    end
  end

  def add_permission_to_children(type)
    scope = :"children_#{type}"
    return unless @permission_params[scope].present?
    @parent_resource.child_media_resources.send(type).find_each do |media_resource|
      add_permission_to_resource(
        resource: media_resource,
        scope: scope
      )
    end
  end

  def find_or_initialize_permission(resource)
    if @receiver.is_a?(User)
      @scope = :userpermission
      Userpermission.find_or_initialize_by(user_id: @receiver.id, media_resource_id: resource.id)
    elsif @receiver.is_a?(Group)
      @scope = :grouppermission
      Grouppermission.find_or_initialize_by(group_id: @receiver.id,
                                            media_resource_id: resource.id)
    end
  end
end
