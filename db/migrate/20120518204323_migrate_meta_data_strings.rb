class MigrateMetaDataStrings < ActiveRecord::Migration
  def up

    MetaDatum.select("meta_data.*").joins(:meta_key).where(meta_keys: {object_type: nil}).each do |md|
      md.string = md.value
      md.save!
    end

    execute <<-SQL
      UPDATE meta_data
        SET type = 'MetaDatumString',
        value = NULL
        WHERE id in (
        SELECT meta_data.id from meta_data, meta_keys
        WHERE true
        AND meta_data.meta_key_id = meta_keys.id
        AND meta_keys.object_type is NULL)
    SQL


  end

  def down
    raise "irreversible migration"
  end
end
