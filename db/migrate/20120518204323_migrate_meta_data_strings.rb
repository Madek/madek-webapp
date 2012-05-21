class MigrateMetaDataStrings < ActiveRecord::Migration

  def migrate_to_string_meta_datum md
    md.string = md.value
    md.save!
    md.update_column :type, "MetaDatumString"
  end

  def up

    MetaDatum.select("meta_data.*").joins(:meta_key).where(meta_keys: {object_type: nil}).each do |md|
      migrate_to_string_meta_datum md
    end

    MetaDatum.select("meta_data.*").joins(:meta_key).where(meta_keys: {object_type: 'MetaCountry'}).each do |md|
      migrate_to_string_meta_datum md
    end

    execute "
      UPDATE meta_data
        SET value = NULL
        WHERE type = 'MetaDatumString';
    "


#    execute <<-SQL
#      UPDATE meta_data
#        SET type = 'MetaDatumString',
#        value = NULL
#        WHERE id in (
#        SELECT meta_data.id from meta_data, meta_keys
#        WHERE true
#        AND meta_data.meta_key_id = meta_keys.id
#        AND meta_keys.object_type is NULL)
#    SQL


  end

  def down

    MetaDatumString.all.each do |mds|
      mds.value = mds.string
      mds.string = nil
      mds.save!
      mds.update_column :type, nil
    end

    #raise "not just yet"
  end

end
