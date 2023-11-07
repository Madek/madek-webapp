class MediaEntries::Duplicator
  include MediaEntries::Duplicator::MetaData
  include MediaEntries::Duplicator::Permissions
  include MediaEntries::Duplicator::Relations

  def initialize(originator, user, config = {})
    raise TypeError unless originator.is_a?(MediaEntry)
    raise TypeError unless user.is_a?(User)
    @originator = originator
    @user = user
    @config = MediaEntries::Duplicator::Configuration.new(config)
  end

  def call
    copy_media_entry

    ActiveRecord::Base.transaction do
      if config.copy_timestamps
        with_disabled_triggers { media_entry.save(validate: false) }
      else
        media_entry.save(validate: false)
      end
      copy_meta_data if config.copy_meta_data
      copy_permissions if config.copy_permissions
      copy_relations if config.copy_relations
      move_custom_urls if config.move_custom_urls
      annotate_as_new_version_of if config.annotate_as_new_version_of
    end

    media_entry
  end

  private

  attr_reader :originator, :user, :media_entry, :config

  def with_disabled_triggers
    ActiveRecord::Base.connection.execute 'SET session_replication_role = REPLICA;'
    yield
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
  end

  def copy_media_entry
    new_media_entry = originator.dup
    new_media_entry.is_published = determine_published_state
    new_media_entry.responsible_user = user
    if config.copy_timestamps
      new_media_entry.created_at = originator.created_at
      new_media_entry.updated_at = originator.updated_at
    end
    @media_entry = new_media_entry
  end

  def determine_published_state
    originator.is_published && config.copy_meta_data
  end

  def annotate_as_new_version_of
    MetaDatum::MediaEntry.create!(
      meta_key_id: 'madek_core:is_new_version_of',
      media_entry: media_entry,
      string: I18n.t(:media_entry_duplicator_new_version_of_label),
      other_media_entry_id: originator.id,
      created_by: originator.creator
    )
  end
end
