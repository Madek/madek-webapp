class API::PermissionRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  property :view
  property :download, as: :download_original
  property :edit, as: :edit_metadata
  property :manage, as: :manage_permissions
end


