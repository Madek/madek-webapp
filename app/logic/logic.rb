module Logic
  extend self
  def data_for_page(media_entries, current_user)
    media_entry_ids = media_entries.map(&:id)

    editable_ids = Permission.accessible_by_user("MediaEntry", current_user, :edit)
    managable_ids = Permission.accessible_by_user("MediaEntry", current_user, :manage)
    
    editable_in_context = editable_ids & media_entry_ids
    managable_in_context = managable_ids & media_entry_ids

    { :pagination => { :current_page => media_entries.current_page,
                       :per_page => media_entries.per_page,
                       :total_entries => media_entries.total_entries,
                       :total_pages => media_entries.total_pages },
      :entries => media_entries.map do |me|
                    permissions = { :is_private => me.acl?(:view, :only, current_user),
                                    :is_public => me.acl?(:view, :all),
                                    :is_editable => (editable_in_context.include?(me.id)),
                                    :is_manageable => (managable_in_context.include?(me.id)) }
                    me.attributes.merge(me.get_basic_info).merge(permissions)
                  end } 
  end

end
