module DevelopmentHelpers
  module DumpAndRestoreTables

    class << self 

      def create_hash tables
        table_name_models = table_name_to_table_names_models tables
        Hash[
          table_name_models.map do |table_name,model| 
            query_chain= 
              if model.attribute_names.include?  model.primary_key
                model.order(model.primary_key)
              else
                model
              end
            [table_name, query_chain.all.collect(&:attributes)]
          end ]
      end

      def import_hash h, tables
        table_name_models = table_name_to_table_names_models tables
        begin 
          ActiveRecord::Base.transaction do
            h.keys.each do |table_name|
              model = table_name_models[table_name] || table_name_models[table_name.to_s]
              model.attribute_names.each { |attr| model.attr_accessible attr}
              h[table_name].each do |attributes|
                model.create attributes
              end
              SQLHelper.reset_autoinc_sequence_to_max model if model.attribute_names.include? "id"
            end
            puts "the data has been imported" 
          end
        rescue Exception => e
          puts "an error has occured #{e}"
        end
      end

      private 

      def table_name_to_table_names_models tables
        Hash[ 
          tables.map do |table_name| 
            klass_name = ("raw_"+table_name).classify
            klass = Class.new(ActiveRecord::Base) do
              self.table_name = table_name
            end
            [table_name,klass]
          end ]
      end

    end
  end
end
