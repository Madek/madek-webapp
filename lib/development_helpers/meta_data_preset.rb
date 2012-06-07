module DevelopmentHelpers
  module MetaDataPreset

    MINIMAL_META_TABLES = [ "meta_keys",
      "meta_terms", "meta_keys_meta_terms",
      "meta_context_groups", "meta_contexts",
      "meta_key_definitions",
      "permission_presets",
      "usage_terms",
      "copyrights"]

    class << self 

      def load_minimal_yaml
        file_name = Rails.root.join("features","data","minimal_meta").to_s + ".yml"
        h = YAML.load File.read file_name
        import_hash h
      end

      def create_hash
        Hash[
          table_name_models.map do |table_name,model| 
            [table_name, model.order(model.primary_key).all.collect(&:attributes)]
          end ]
      end

      def import_hash h
        ActiveRecord::Base.transaction do
          h.keys.each do |table_name|
            model = table_name_models[table_name]
            model.attribute_names.each { |attr| model.attr_accessible attr}
            h[table_name].each do |attributes|
              model.create attributes
            end
            SQLHelper.reset_autoinc_sequence_to_max model
          end
          puts "the meta-data setup has been imported" 
        end
      end

      private 

      def table_name_models
        @__lazy_tabel_name_models ||= 
          Hash[ 
            MINIMAL_META_TABLES.map do |table_name| 
              klass = ("raw_"+table_name).classify
              eval %Q{
                class ::#{klass} < ActiveRecord::Base
                  set_table_name :#{table_name}
                end
              }
              [table_name,klass.constantize]
            end ]
      end

    end
  end
end
