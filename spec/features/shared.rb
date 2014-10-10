module Features
  module Shared

    def visit_user_first_media_entry
      visit media_entry_path(@current_user.media_entries.reorder(:created_at,:id).first)
    end

    def visit_user_first_media_set
      visit media_set_path(@current_user.media_sets.reorder(:created_at,:id).first)
    end

    def get_current_media_resource
      uuid = current_path.match(/\/([\w-]+)$/)[1] 
      MediaResource.find uuid
    end

  end
end

