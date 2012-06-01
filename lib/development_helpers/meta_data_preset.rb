module DevelopmentHelpers
  module MetaDataPreset
    class << self 
      def create_hash
        h = {}

        h[:usage_terms] = UsageTerm.current.attributes

        h[:meta_keys] = MetaKey.order("id").all.collect do |meta_key|
          a = meta_key.attributes
        end

        h[:meta_terms] = MetaTerm.order("id").all.collect(&:attributes)


        h[:meta_contexts] = MetaContext.order("id").all.collect do |meta_context|
          meta_context.attributes.select {|k,v| not v.blank? }
        end

        h[:meta_context_groups] = MetaContextGroup.order("id").all.collect do |meta_context_group|
          meta_context_group.attributes.select {|k,v| not v.blank? }
        end

        h[:meta_key_definitions] = MetaKeyDefinition.order("id").all.collect do |meta_key_definition|
          meta_key_definition.attributes.select {|k,v| not v.blank? and not k =~ /ated_at$/ }
        end

        h[:permission_presets] = PermissionPreset.order("id").all.collect do |permission_preset|
          permission_preset.attributes.select {|k,v| not v.blank? and not k =~ /ated_at$/ }
        end

        #future#
        #      h[:copyrights] = Copyright.all.collect(&:attributes)


        h
      end 
    end
  end
end
