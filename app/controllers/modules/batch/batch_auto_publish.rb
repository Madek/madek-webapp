module Modules
  module Batch
    module BatchAutoPublish

      private

      def batch_publish_transaction!(media_entries)
        published_before_count = 0
        total_count = 0
        media_entries.each do |media_entry|
          total_count += 1
          published_before_count += 1 if media_entry.is_published
        end

        to_publish_count = execute_publish(media_entries)

        published_after_count = 0
        media_entries.reload.each do |media_entry|
          published_after_count += 1 if media_entry.is_published
        end

        {
          total_count: total_count,
          published_before_count: published_before_count,
          to_publish_count: to_publish_count,
          published_after_count: published_after_count
        }
      end

      def flash_message_by_stats(stats)
        message = flash_message_total(stats)
        message += '<br/>('
        message + flash_message_parts(stats)
      end

      def flash_message_total(stats)
        message = t('meta_data_batch_summary_all_pre')
        message += stats[:total_count].to_s
        message + t('meta_data_batch_summary_all_post')
      end

      def flash_message_parts(stats)
        message = stats[:to_publish_count].to_s
        message += t('meta_data_batch_summary_published')
        message += ', ' + stats[:published_before_count].to_s
        message += t('meta_data_batch_summary_were_published')
        message += ', '
        message += (stats[:total_count] - stats[:published_after_count]).to_s
        message += t('meta_data_batch_summary_missing')
        message + ')'
      end

      def execute_publish(media_entries)
        to_publish = determine_entries_for_autopublish(media_entries)
        ActiveRecord::Base.transaction do
          to_publish.each do |media_entry|
            media_entry.is_published = true
            media_entry.save!
          end
        end
        to_publish.length
      end

      def get_validation_keys()
        validation_keys = ContextKey.where(
          context: AppSetting.first.contexts_for_entry_validation,
          is_required: true)

        validation_keys.select do |context_key|
          vocab = context_key.meta_key.vocabulary
          viewable = vocab.viewable_by_public? || vocab.viewable_by_user?(@user)
          enabled = context_key.meta_key.send('is_enabled_for_media_entries')
          viewable && enabled
        end
      end

      def validate_media_entry(media_entry, validation_keys)
        all_valid = true

        validation_keys.each do |context_key|

          datums_for_key = media_entry.meta_data.select do |meta_datum|
            meta_datum.meta_key_id == context_key.meta_key_id
          end

          if datums_for_key.length != 1
            all_valid = false
          else
            datum_for_key = datums_for_key[0]

            unless valid(datum_for_key)
              all_valid = false
            end
          end
        end

        all_valid
      end

      def is_autopublishable(media_entry)
        return false if media_entry.is_published
        validation_keys = get_validation_keys()
        validate_media_entry(media_entry, validation_keys)
      end

      def determine_entries_for_autopublish(media_entries)
        validation_keys = get_validation_keys()
        media_entries.select do |media_entry|
          !media_entry.is_published && validate_media_entry(media_entry, validation_keys)
        end
      end

      def determine_valid_entries(media_entries)
        validation_keys = get_validation_keys()
        media_entries.select do |media_entry|
          validate_media_entry(media_entry, validation_keys)
        end
      end

      def valid(meta_datum)
        meta_datum.value.presence
      end
    end
  end
end
