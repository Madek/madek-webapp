module Modules
  module Batch
    module BatchEditTitle
      extend ActiveSupport::Concern

      include Modules::Batch::BatchShared
      include Modules::Batch::BatchAutoPublish

      def batch_edit_title_select
        auth_authorize User, :logged_in?
        
        resource_ids = params.require(:resource_id)
        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        media_entries = get_authorized_media_entries(media_entry_ids)

        return_to = params.require(:return_to)

        respond_with({
          resource_ids: resource_ids,
          media_entries: media_entries.map do |entry|
            {
              id: entry.id,
              title: entry.meta_data.find_by(meta_key_id: 'madek_core:title').try(:to_s),
              file_name: entry.media_file.filename,
              image_url: get_image_url(entry)
            }
          end,
          return_to: return_to
        })
      end

      def batch_edit_title_update
        auth_authorize User, :logged_in?
        
        resource_ids = params.require(:resource_id)
        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        media_entries = get_authorized_media_entries(media_entry_ids)
        
        return_to = params.require(:return_to)
  
        title_form_values = params.require(:titles)

        media_entries.each do |entry|
          title_from_form = title_form_values[entry.id.to_s]
          raise "Found empty title" unless title_from_form.present? # (should be prevented by UI)
          set_media_entry_title(entry, title_from_form)
          set_default_values(entry)
        end

        published_before_count = media_entries.select(&:is_published).count
        valid_entries_count = determine_valid_entries(media_entries).count
        newly_published_count = execute_publish(media_entries)

        stats = {
          total_count: media_entries.count,
          to_publish_count: valid_entries_count,
          published_before_count: published_before_count,
          published_after_count: published_before_count + newly_published_count
        }

        flash[:success] = flash_message_by_stats(stats)
        redirect_to(return_to)
      end

      private

      def get_image_url(media_entry)
        size = :small
        imgs = Presenters::MediaFiles::MediaFile.new(media_entry, current_user)
          .try(:previews).try(:[], :images)
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        img.url if img.present?
      end

      def get_authorized_media_entries(media_entry_ids)
        media_entries = MediaEntry.unscoped.where(id: media_entry_ids)
        authorize_media_entries_scope!(current_user, media_entries, MediaResourcePolicy::EditableScope)
        media_entry_ids.map { |id| media_entries.find { |entry| entry.id == id } }.compact
      end

      def set_media_entry_title(entry, title)
        meta_key = MetaKey.find_by(id: 'madek_core:title')
        write_text_meta_datum(meta_key, entry, title)
      end

      def set_default_values(entry)
        default_text = AppSetting.first.copyright_notice_default_text
        return unless default_text
        meta_key = MetaKey.find_by(id: 'madek_core:copyright_notice')
        write_text_meta_datum(meta_key, entry, default_text, only_when_empty: true)
      end

      def write_text_meta_datum(meta_key, media_entry, text, only_when_empty: nil)
        raise 'meta key is not of type MetaDatum::Text' unless meta_key.meta_datum_object_type == 'MetaDatum::Text'
        meta_datum = MetaDatum::Text.find_by(meta_key: meta_key, media_entry: media_entry)
        if meta_datum
          meta_datum.value = text unless only_when_empty and meta_datum.value.present?
        else
          meta_datum = MetaDatum::Text.create_with_user!(current_user, { meta_key: meta_key, media_entry: media_entry, value: text})
        end
        meta_datum.save!
      end

    end
  end
end
