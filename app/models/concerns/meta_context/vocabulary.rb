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
            meta_terms: MetaTerm.joins(meta_keys: :meta_key_definitions) 
              .where("meta_key_definitions.id = ?",mkd.id)
              .order(:term).map{ |mt| 
                mt.attributes.symbolize_keys
                  .merge(usage_count: usage_count(mkd,mt,user))})}
        .map(&:deep_symbolize_keys)
    end

  end
end
