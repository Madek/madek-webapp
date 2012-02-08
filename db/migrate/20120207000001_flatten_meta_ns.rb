class FlattenMetaNs < ActiveRecord::Migration

  def up

    Group.update_all("type = REPLACE(type, 'Meta::', 'Meta')")
    MetaKey.update_all("object_type = REPLACE(object_type, 'Meta::', 'Meta')")

  end

  def down
  end

end
