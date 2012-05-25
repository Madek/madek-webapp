module DevelopmentHelpers
  module MetaDataPreset
    class << self 
      def create_hash
        h = {}

        h[:meta_terms] = MetaTerm.all.collect(&:attributes)

        h[:meta_keys] = MetaKey.all.collect do |meta_key|
          a = meta_key.attributes
          a["meta_terms"] = meta_key.meta_terms.collect(&:id) if meta_key.object_type == "MetaTerm"
          a
        end

        h[:meta_context_groups] = MetaContextGroup.all.collect do |meta_context_group|
          meta_context_group.attributes.select {|k,v| not v.blank? }
        end

        h[:meta_contexts] = MetaContext.all.collect do |meta_context|
          meta_context.attributes.select {|k,v| not v.blank? }
        end

        h[:meta_key_definitions] = MetaKeyDefinition.all.collect do |meta_key_definition|
          meta_key_definition.attributes.select {|k,v| not v.blank? and not k =~ /ated_at$/ }
        end

        h[:permission_presets] = PermissionPreset.all.collect do |permission_preset|
          permission_preset.attributes.select {|k,v| not v.blank? and not k =~ /ated_at$/ }
        end

        #future#
        #      h[:copyrights] = Copyright.all.collect(&:attributes)

        h[:usage_terms] = UsageTerm.current.attributes

        h
      end 
    end
  end
end
