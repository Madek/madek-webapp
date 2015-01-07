module Permissions
  class FilterSetUserPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    belongs_to :user

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         edit_metadata_and_filter: false,
         edit_permissions: false }]) do
           joins(:filter_set).where("filter_sets.responsible_user_id \
              = filter_set_user_permissions.user_id").delete_all
         end
  end
end
