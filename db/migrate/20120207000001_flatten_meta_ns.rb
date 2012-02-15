class FlattenMetaNs < ActiveRecord::Migration

  def up

    Group.update_all("type = REPLACE(type, 'Meta::', 'Meta')")
    MetaKey.update_all("object_type = REPLACE(object_type, 'Meta::', 'Meta')")
    MetaDatum.update_all("value = REPLACE(value, 'Meta::', 'Meta')")

  end

  def down
  end

end
