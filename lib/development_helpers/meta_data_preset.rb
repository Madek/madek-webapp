module DevelopmentHelpers
  module MetaDataPreset

    class << self 
      MODELS= ["MetaKey", 
        "MetaTerm", "MetaKeyMetaTerm", 
        "MetaContextGroup", "MetaContext", 
        "MetaKeyDefinition", 
        "PermissionPreset"]

      def create_hash
        h = {}
        MODELS.map(&:constantize).each do |model| 
          h[model.table_name] = model.order(model.primary_key).all.collect(&:attributes)
        end
        h
      end

      def load_minimal_yaml
        file_name = Rails.root.join("features","data","minimal_meta").to_s + ".yml"
        h = YAML.load File.read file_name
        import_hash h
      end

      def import_hash h

        table_names_models = {}

        MODELS.map(&:constantize).each do |model|
          table_names_models[model.table_name] = model
        end


        ActiveRecord::Base.transaction do
          h.keys.each do |table_name|
            puts table_name
            klass = table_names_models[table_name]
            puts klass
            klass.attribute_names.each { |attr| klass.attr_accessible attr}
            h[table_name].each do |attributes|
              klass.create attributes
            end
            SQLHelper.reset_autoinc_sequence_to_max klass
          end
        end
      end
    end
  end
end
