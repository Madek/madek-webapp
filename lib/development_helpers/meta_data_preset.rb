module DevelopmentHelpers
  module MetaDataPreset

    class << self 

      def load_minimal_yaml
        file_name = File.join(Rails.root, "features", "data", "minimal_meta.yml")
        h = YAML.load_file file_name
        DBHelper.import_hash h, Constants::MINIMAL_META_TABLES
      end

      def create_hash
        DBHelper.create_hash Constants::MINIMAL_META_TABLES
      end
      
      def import_context(name)
        return if MetaContext.exists?(name: name)
        
        file_name = File.join(Rails.root, "features", "data", "minimal_meta.yml") # TODO ?? persona_base_meta.yml
        h = YAML.load_file file_name
        c = h["meta_contexts"].detect{|x| x["name"] == name}
        
        hh = {
          name: c["name"],
          label: h["meta_terms"].detect{|x| x["id"] == c["label_id"]},
          description: h["meta_terms"].detect{|x| x["id"] == c["description_id"]}
        }
        hh.delete_if {|k,v| v.nil?}
        meta_context = MetaContext.create(hh)
        
        h["meta_key_definitions"].select{|x| x["meta_context_id"] == c["id"]}.each do |d|
          hh = {
            meta_key: begin
              dd = h["meta_keys"].detect{|x| x["id"] == d["meta_key_id"]}
              dd.delete("id")
              MetaKey.find_or_create_by_label(dd)
            end,
            position: d["position"],
            key_map: d["key_map"],
            key_map_type: d["key_map_type"],
            settings: YAML.load(d["settings"]),
            label: h["meta_terms"].detect{|x| x["id"] == d["label_id"]},
            description: h["meta_terms"].detect{|x| x["id"] == d["description_id"]},
            hint_id: h["meta_terms"].detect{|x| x["id"] == d["hint_id"]}
          }
          hh.delete_if {|k,v| v.nil?}
          meta_context.meta_key_definitions.create(hh)
        end
        
      end

    end
  end
end
