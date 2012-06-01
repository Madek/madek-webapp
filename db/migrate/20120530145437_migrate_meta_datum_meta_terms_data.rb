module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_meta_term rmd
        mdp = MetaDatumMetaTerms.find rmd.id
        YAML.load(rmd.value).each do |id|
          md = MetaTerm.find(id)
          mdp.meta_terms <<  md unless mdp.meta_terms.include?(md)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_meta_terms
      
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaTerm'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumMetaTerms"
          migrate_meta_datum_meta_term rmd
        end

        MetaKey.where("object_type = 'MetaTerm'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumMetaTerms'
        end

      end
    end
  end
end


class MigrateMetaDatumMetaTermsData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_meta_terms
  end

  def down
    # raise "this is a irreversible migration"
  end
end
