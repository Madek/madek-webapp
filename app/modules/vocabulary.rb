# This model contains functions which are solely used 
# for building the Vocabulary 
#
module Vocabulary
  class << self

    def usage_count context, meta_key_definition, meta_term, user
      MediaEntry.accessible_by_user(user,:view) 
        .joins(meta_data_meta_terms: {meta_terms: {meta_keys: :contexts}}) 
        .where("meta_key_definitions.id = ?", meta_key_definition.id) 
        .where("meta_terms.id = ?",meta_term.id) 
        .where("contexts.id= ?",context.id) 
        .limit(9999).count
    end

    def build_for_context_and_user context, user
      MetaKeyDefinition.joins(:context) 
        .where("contexts.id= ?",context.id) 
        .order(:label).map{ |mkd|
          mkd.attributes.merge(
            meta_terms: MetaTerm.joins(meta_keys: :meta_key_definitions) 
              .where("meta_key_definitions.id = ?",mkd.id)
              .order(:term).map{ |mt| 
                mt.attributes.symbolize_keys
                  .merge(usage_count: usage_count(context,mkd,mt,user))})}
        .map(&:deep_symbolize_keys)
    end

    # TODO remove duplication here
    def build_for_context_set_and_user context, set, user
      MetaKeyDefinition.joins(:context) 
        .where("contexts.id= ?",context.id) 
        .order(:label).map{ |mkd|
          mkd.attributes.merge(
            meta_terms: MetaTerm.joins(meta_keys: :meta_key_definitions) 
              .where("meta_terms.id in ( #{meta_terms_for_set(set).select('meta_terms.id').to_sql} )")
              .where("meta_key_definitions.id = ?",mkd.id)
              .order(:term).map{ |mt| 
                mt.attributes.symbolize_keys
                  .merge(usage_count: usage_count(context,mkd,mt,user))})}
        .map(&:deep_symbolize_keys)
    end

    def meta_terms_for_set set
      MetaTerm \
        .joins(%< 
          INNER JOIN meta_data_meta_terms AS mdmts ON mdmts.meta_term_id = meta_terms.id
          INNER JOIN meta_data ON meta_data.id = mdmts.meta_datum_id
          INNER JOIN media_resources AS entries ON entries.id = meta_data.media_resource_id
          INNER JOIN media_resource_arcs ON media_resource_arcs.child_id = entries.id
          INNER JOIN media_resources AS sets ON sets.id = media_resource_arcs.parent_id
          >)
        .where(%< entries.type = 'MediaEntry'>)
        .where(%< sets.id = ? >, set.id)
    end


    def media_entries context, user
      MediaEntry.accessible_by_user(user,:view) 
      .joins("INNER JOIN media_resource_arcs ON child_id = media_resources.id")
      .joins("INNER JOIN media_resources AS parents ON parent_id = parents.id")
      .joins("INNER JOIN media_sets_contexts ON media_set_id = parents.id")
      .joins("INNER JOIN contexts ON contexts.id= context_id")
      .where("contexts.id= ?",context.id)
    end

    def media_entries_count context, user
      media_entries(context,user).count
    end


  end
end
