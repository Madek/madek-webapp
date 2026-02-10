module Presenters
  module MediaEntries
    class MediaEntryNew < Presenter

      def initialize(user, copy_md_from: nil)
        super()
        @user = user
        @copy_md_from = copy_md_from
        raise TypeError if !@copy_md_from.nil? && !@copy_md_from.is_a?(MediaEntry)
      end

      def next_step
        if copy_md_from&.published?
          {
            label: I18n.t(:media_entry_media_import_gotomediaentries),
            url: prepend_url_context(my_dashboard_section_path(:content_media_entries))
          }
        else
          {
            label: I18n.t(:media_entry_media_import_gotodrafts),
            url: prepend_url_context(my_dashboard_section_path(:unpublished_entries))
          }
        end
      end

      def copy_md_from
        Presenters::MediaEntries::MediaEntryIndex.new(@copy_md_from, @user) if @copy_md_from
      end

      def duplicator_defaults
        if @copy_md_from
          ::MediaEntries::Duplicator::Configuration::DEFAULTS
            .slice(:copy_meta_data, :copy_permissions, :copy_relations, :annotate_as_new_version_of,
                   :move_custom_urls)
        end
      end
    end
  end
end
