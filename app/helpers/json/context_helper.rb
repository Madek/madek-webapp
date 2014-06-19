module Json
  module ContextHelper

    def hash_for_context(context, with = nil)

      h = {
        name: context.id,
        label: context.label.to_s,
        description: context.description.to_s
      }
      
      if with ||= nil
        if with[:meta_keys]
          h[:meta_keys] = context.meta_key_definitions.map do |mkd|
            {
              id: mkd.meta_key.id,
              name: mkd.meta_key.label, # TODO td: translate .label to .name
              label: mkd.label.to_s,
              hint: mkd.hint.to_s,
              description: mkd.description.to_s,
              type: MetaDatum.value_type_name(mkd.meta_key.meta_datum_object_type),
              is_extensible_list: mkd.meta_key.is_extensible_list,
              settings: {is_required: mkd.is_required, length_min: mkd.length_min, length_max: mkd.length_max}
            }
          end
        end 

        if with[:vocabulary]
          h[:vocabulary] = vocabulary(context, nil, false)
        end

        if with[:abstract]
          h[:abstract] = context.abstract(current_user)
        end
      end 
      
      h
    end

    def vocabulary(context, used_meta_term_ids = nil, include_parent = true)
      # TODO drop the include_parent argument
      r = include_parent ? hash_for(context) : {}
      
      used_meta_term_ids ||= context.used_meta_term_ids(current_user)
      r[:meta_keys] = context.meta_keys.for_meta_terms.map do |meta_key|
        definition = meta_key.meta_key_definitions.for_context(context)
        { :label => definition.label.to_s,
          :meta_terms => meta_key.meta_terms.map do |meta_term|
            { :id => meta_term.id,
              :label => meta_term.to_s,
              :is_used => used_meta_term_ids.include?(meta_term.id)
            }
          end
        }
      end
      r
    end

  end
end
      
