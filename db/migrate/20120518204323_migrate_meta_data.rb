module MigrationHelpers
  module MetaDatum
    class << self
      
      def migrate_meta_strings
        type = "MetaDatumString"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'MetaCountry' OR meta_keys.object_type is NULL").where("type is NULL or type = 'MetaDatum' ")
        ids.where("value like '%(Binary data % bytes)%' OR value like '%!binary |%'").destroy_all
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          value = YAML.load(rmd.value)
          rmd.update_attributes string: value
          rmd.update_column :type, type
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or rmd.string != value
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, "object_type is NULL OR object_type = 'MetaCountry'")
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end
  
      def migrate_meta_dates
        type = "MetaDatumDate"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'MetaDate'").where("type is NULL or type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          obj = YAML.load rmd.value.gsub(/^-\s+.*\n/, "")
          value = obj.is_a?(Hash) ? obj.try(:fetch,"free_text").try(:strip) : ""
          rmd.update_attributes string: value
          rmd.update_column :type, type
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or rmd.string != value
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, "object_type = 'Date' OR object_type = 'MetaDate'") 
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

      def migrate_meta_people
        type = "MetaDatumPeople" 
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'Person'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, type
          mdp = MetaDatumPeople.find rmd.id
          new_value = Person.where(:id => YAML.load(rmd.value))
          mdp.people << new_value 
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or not mdp.persisted? or mdp.people.sort != new_value.sort
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'Person'})
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

      def migrate_meta_datum_departments
        type = "MetaDatumDepartments"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'MetaDepartment'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, type
          mdp = MetaDatumDepartments.find rmd.id
          new_value = MetaDepartment.where(:id => YAML.load(rmd.value)).map {|md| md unless mdp.meta_departments.include?(md) }.compact
          mdp.meta_departments << new_value
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or not mdp.persisted? or mdp.meta_departments.sort != new_value.sort
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'MetaDepartment'})
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

      def migrate_meta_datum_keywords
        type = "MetaDatumKeywords"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'Keyword'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, type
          mdp = MetaDatumKeywords.find rmd.id
          old_value = Keyword.where(:id => YAML.load(rmd.value)).group(:meta_term_id)
          new_value = old_value.map do |keyword|
            keyword = keyword.dup unless keyword.meta_datum_id.nil? 
            keyword.update_attributes(:meta_datum => mdp)
            keyword
          end
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or mdp.keywords.sort != new_value.sort or old_value.size != new_value.size
        end
        Keyword.delete_all(:meta_datum_id => nil)
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'Keyword'})
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

      def migrate_meta_datum_meta_terms
        type = "MetaDatumMetaTerms"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'MetaTerm'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, type
          mdp = MetaDatumMetaTerms.find rmd.id
          new_value = MetaTerm.where(:id => YAML.load(rmd.value)).map {|md| md unless mdp.meta_terms.include?(md) }.compact
          mdp.meta_terms << new_value
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or not mdp.persisted? or mdp.meta_terms.sort != new_value.sort
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'MetaTerm'})
        # test #
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

      def migrate_meta_datum_users
        type = "MetaDatumUsers"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'User'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, type
          mdp = MetaDatumUsers.find rmd.id
          new_value = User.where(:id => YAML.load(rmd.value)).map {|md| md unless mdp.users.include?(md) }.compact
          mdp.users << new_value
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or not mdp.persisted? or mdp.users.sort != new_value.sort
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'User'})
        # test #
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end
  
      def migrate_meta_datum_copyrights
        type = "MetaDatumCopyright"
        base_ids = RawMetaDatum.select("meta_data.id").joins(:meta_key)
        # test #          
        ids = base_ids.where("meta_keys.object_type = 'Copyright'").where("type is NULL OR type = 'MetaDatum'")
        count_before = ids.count
        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          value = YAML.load(rmd.value)[0]
          rmd.update_column :copyright_id, value
          rmd.update_column :type, type
          # test #
          raise "migration failed: #{type}" if not rmd.persisted? or rmd.copyright_id != value
        end
        MetaKey.update_all({object_type: nil, meta_datum_object_type: type}, {object_type: 'Copyright'})
        # test #          
        ids = base_ids.where(meta_keys: {meta_datum_object_type: type}, type: type)
        count_after = ids.count
        raise "migration failed: #{type}" unless count_before == count_after
      end

    end
  end
end

class MigrateMetaData < ActiveRecord::Migration

  def up
    transaction do
      MigrationHelpers::MetaDatum.migrate_meta_strings
      MigrationHelpers::MetaDatum.migrate_meta_dates
      MigrationHelpers::MetaDatum.migrate_meta_people
      MigrationHelpers::MetaDatum.migrate_meta_datum_departments
      MigrationHelpers::MetaDatum.migrate_meta_datum_keywords
      MigrationHelpers::MetaDatum.migrate_meta_datum_meta_terms
      MigrationHelpers::MetaDatum.migrate_meta_datum_users
      MigrationHelpers::MetaDatum.migrate_meta_datum_copyrights

      remove_column :meta_keys, :object_type
      remove_column :meta_data, :value
    end
  end

  def down
    raise "this is a irreversible migration"
  end

end
