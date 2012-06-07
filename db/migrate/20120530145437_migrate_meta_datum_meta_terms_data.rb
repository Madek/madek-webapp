module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_meta_term rmd
        mdp = MetaDatumMetaTerms.find rmd.id
        ids = YAML.load(rmd.value)
        MetaTerm.where(:id => ids).each do |md|
          mdp.meta_terms << md unless mdp.meta_terms.include?(md)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_meta_terms
        RawMetaDatum.joins(:meta_key)
        .where("meta_keys.object_type = 'MetaTerm'")
        .where("type is NULL OR type = 'MetaDatum'").each do |rmd|
          rmd.update_column :type, "MetaDatumMetaTerms"
          migrate_meta_datum_meta_term rmd
        end

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumMetaTerms'},
                           {object_type: 'MetaTerm'})

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
