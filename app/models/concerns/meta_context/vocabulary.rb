module Concerns
  module MetaContext::Vocabulary
    extend ActiveSupport::Concern

    def usage_count meta_key_definition, meta_term, user
      MediaEntry.accessible_by_user(user,:view) 
        .joins(meta_data_meta_terms: {meta_terms: {meta_keys: :meta_contexts}}) 
        .where("meta_key_definitions.id = ?", meta_key_definition.id) 
        .where("meta_terms.id = ?",meta_term.id) 
        .where("meta_contexts.name = ?",self.name) 
        .limit(9999).count
    end

    def build_vocabulary user
      MetaKeyDefinition.joins(:meta_context) 
        .where("meta_contexts.name = ?",name) 
        .order(:label).map{ |mkd|
          mkd.attributes.merge(
            meta_key_meta_terms_alphabetical_order: \
              MetaKey.find_by(id: mkd.meta_key_id).meta_terms_alphabetical_order,
            meta_terms: MetaTerm.joins(meta_keys: :meta_key_definitions) 
              .where("meta_key_definitions.id = ?",mkd.id)
              .order(:term).map{ |mt| 
                mt.attributes.symbolize_keys
                  .merge(usage_count: usage_count(mkd,mt,user))})}
        .map(&:deep_symbolize_keys)
    end

    def media_entries user
      MediaEntry.accessible_by_user(user,:view) 
      .joins("INNER JOIN media_resource_arcs ON child_id = media_resources.id")
      .joins("INNER JOIN media_resources AS parents ON parent_id = parents.id")
      .joins("INNER JOIN media_sets_meta_contexts ON media_set_id = parents.id")
      .joins("INNER JOIN meta_contexts ON meta_contexts.name = meta_context_name")
      .where("meta_contexts.name = ?",name)
    end

    def media_entries_count user
      media_entries(user).count
    end

  end
end
