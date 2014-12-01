module Permissions

  class FilterSetUserPermission < ActiveRecord::Base

    belongs_to :filter_set
    belongs_to :user
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      FilterSetUserPermission.where(get_metadata_and_previews: false, 
                                    edit_metadata_and_filter: false, 
                                    edit_permissions: false).delete_all

      FilterSetUserPermission.joins(:filter_set).where(
        "filter_sets.responsible_user_id = filter_set_user_permissions.user_id") \
        .delete_all()
    end

  end

end
