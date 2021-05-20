module MediaEntries::Duplicator::Relations
  private

  def copy_relations
    copy_assignment_to_collections
    copy_assignment_to_favorites # ?
  end

  def copy_assignment_to_collections
    accessible_parent_collections.each do |parent_collection|
      parent_collection.media_entries << media_entry
    end
  end

  def copy_assignment_to_favorites
    media_entry.users_who_favored << originator.users_who_favored
  end

  def move_custom_urls
    originator.custom_urls.update_all(media_entry_id: media_entry.id)
  end

  def accessible_parent_collections
    originator.parent_collections.select do |parent_collection|
      Pundit.policy!(user, parent_collection).add_remove_collection?
    end
  end
end
