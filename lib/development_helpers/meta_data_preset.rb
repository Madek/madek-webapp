module DevelopmentHelpers
  module MetaDataPreset

    class << self 

      def load_minimal_yaml
        file_name = Rails.root.join("features","data","minimal_meta").to_s + ".yml"
        h = YAML.load File.read file_name
        DevelopmentHelpers::DumpAndRestoreTables.import_hash h, Constants::MINIMAL_META_TABLES
      end

      def create_hash
        DevelopmentHelpers::DumpAndRestoreTables.create_hash Constants::MINIMAL_META_TABLES
      end

    end
  end
end
