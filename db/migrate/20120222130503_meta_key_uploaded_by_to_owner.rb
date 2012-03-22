class MetaKeyUploadedByToOwner < ActiveRecord::Migration
  def up

    if (meta_key = MetaKey.find_by_label("uploaded by"))
      meta_key.update_attributes(object_type: "User", is_dynamic: false)
      
      MediaResource.media_entries_or_media_entry_incompletes.each do |me|
        me.meta_data.create(:meta_key => meta_key, :value => me.user)
      end

      MetaKey.create(label: "owner", object_type: "User", is_dynamic: true)
    end

  end

  def down
  end
end
