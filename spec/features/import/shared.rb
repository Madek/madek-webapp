module Features
  module Import
    module Shared
      DEFAULT_TIMEOUT = 5

      def attach_test_file(filename)
        @files_to_upload ||= 0
        attach_file find("input[type='file']", visible: false)[:id], Rails.root.join('spec', 'data', filename), visible: false
        page.execute_script %Q{ $('#import-start').removeClass('disabled') }
        @files_to_upload += 1
      end

      def expect_exactly_one_media_entry_with_filename_matching(matcher)
        expect(MediaEntry.all.select { |me| me.media_file.filename =~ /#{matcher}/ }.size).to eq(1)
      end

      def expect_import_permissions_page
        expect(page).to have_content('Zugriff und Sichtbarkeit festlegen')
        assert_exact_url_path '/import/permissions'
      end

      def expect_new_media_entries(count)
        new_media_entries = MediaEntry.all - @previous_media_entries
        expect(new_media_entries.size).to eq count
      end

      def expect_new_media_entry_with_title(title)
        new_media_entries = MediaEntry.all - @previous_media_entries
        expect(new_media_entries.map(&:title)).to include(title)
      end

      def expect_no_incomplete_media_entry_with_filename_matching(matcher)
        expect(MediaEntryIncomplete.all.select{ |me| me.media_file.filename =~ /#{matcher}/ }.size).to eq(0)
      end

      def fill_meta_key_field_with(value, meta_key_id)
        within find("fieldset[data-meta-key='#{meta_key_id}']") do
          find('input, textarea').set(value)
        end
      end

      def remember_resources
        @previous_media_entries = MediaEntry.all.to_a
        @previous_media_sets = MediaSet.all.to_a
        @previous_zencoder_jobs = ZencoderJob.all.to_a
      end

      def remove_incomplete_media_entries_with_filename_matching(matcher)
        MediaEntryIncomplete.all.
          select { |me| me.media_file.filename =~ /#{matcher}/ }.each(&:destroy)
      end

      def remove_media_entries_with_filename_matching(matcher)
        MediaEntry.all.
          select{ |me| me.media_file.filename =~ /#{matcher}/ }.each(&:destroy)
      end

      def start_uploading(timeout = DEFAULT_TIMEOUT)
        click_link 'import-start'
        wait_for_file_upload(timeout)
      end

      def wait_for_file_upload(timeout = DEFAULT_TIMEOUT)
        Timeout.timeout(timeout * @files_to_upload) do
          loop do
            no_remaining_uploads = page.evaluate_script %Q{ $(".plupload_content li:not(.plupload_done):visible").length == 0 }
            visible_upload_statuses = page.evaluate_script %Q{ $(".plupload_content li:visible").length == #{@files_to_upload} }
            break if no_remaining_uploads && visible_upload_statuses
          end
        end
      end
    end
  end
end
