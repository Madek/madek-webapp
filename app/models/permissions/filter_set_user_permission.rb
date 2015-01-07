module Permissions
  class FilterSetUserPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    belongs_to :user

    def self.destroy_ineffective
      where(get_metadata_and_previews: false,
            edit_metadata_and_filter: false,
            edit_permissions: false).delete_all

      joins(:filter_set).where("filter_sets.responsible_user_id \
        = filter_set_user_permissions.user_id") \
        .delete_all
    end

  end

end
