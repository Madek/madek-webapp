module Presenters
  module Shared
    module MediaResource
      module Modules
        module SectionLabels
          def section_labels(section_meta_key_id, media_resource)
            return nil unless section_meta_key_id.present?
    
            meta_datum = media_resource.meta_data.where(meta_key: section_meta_key_id).first
            return [] unless meta_datum.present?
    
            meta_datum.keywords
              .sort_by { |k| meta_datum.meta_key.keywords_alphabetical_order ? k.term : k.position }
              .map { |k| k.section }
              .filter { |s| s.present? }
              .map do |s|
                {
                  keyword_id: s.keyword.id,
                  label: localize(s.labels),
                  color: s.color,
                  href: s.index_collection ? collection_path(s.index_collection) : nil
                }
              end
          end
        end
      end
    end
  end
end
