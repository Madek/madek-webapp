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
            h_title: I18n.t(:collection_resource_selection_h_title),
            h_subtitle: I18n.t(:collection_resource_selection_h_subtitle),
            h_author: I18n.t(:collection_resource_selection_h_author),
            h_date: I18n.t(:collection_resource_selection_h_date),
            h_keywords: I18n.t(:collection_resource_selection_h_keywords),
            h_responsible: I18n.t(:collection_resource_selection_h_responsible)
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
