module Concerns
  module Context::Vocabulary
    extend ActiveSupport::Concern

    def usage_count meta_key_definition, meta_term, user
      MediaEntry.accessible_by_user(user,:view) 
        .joins(meta_data_meta_terms: {meta_terms: {meta_keys: :contexts}}) 
        .where("meta_key_definitions.id = ?", meta_key_definition.id) 
        .where("meta_terms.id = ?",meta_term.id) 
        .where("contexts.id= ?",self.id) 
        .limit(9999).count
    end

    def build_vocabulary user
      MetaKeyDefinition.joins(:context) 
        .where("contexts.id= ?",id) 
        .order(:label).map{ |mkd|
          mkd.attributes.merge(
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
      .joins("INNER JOIN media_sets_contexts ON media_set_id = parents.id")
      .joins("INNER JOIN contexts ON contexts.id= context_id")
      .where("contexts.id= ?",id)
    end

    def media_entries_count user
      media_entries(user).count
    end

  end
end
