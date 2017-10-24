module Presenters
  module Collections
    module Modules
      module CollectionResourceSelection
        extend ActiveSupport::Concern

        attr_reader :child_presenters

        def i18n
          {
            title: 'TODO',
            cancel: I18n.t(:collection_resource_selection_cancel),
            save: I18n.t(:collection_resource_selection_save),
            h_selection: I18n.t(:collection_resource_selection_h_selection),
            h_title: MetaKey.find('madek_core:title').label,
            h_subtitle: MetaKey.find('madek_core:subtitle').label,
            h_author: MetaKey.find('madek_core:authors').label,
            h_date: I18n.t(:collection_resource_selection_h_date),
            h_keywords: MetaKey.find('madek_core:keywords').label,
            h_responsible: MetaKey.find('madek_core:copyright_notice').label
          }
        end

        def uuid_to_checked_hash
          raise 'not implemented'
        end

        def submit_url
          raise 'not implemented'
        end

        def cancel_url
          raise 'not implemented'
        end

      end
    end
  end
end
