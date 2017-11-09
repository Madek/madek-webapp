class ChangeUserNameField < ActiveRecord::Migration[5.0]
  class MigrationField < ActiveRecord::Base
    self.table_name = 'fields'
  end

  OLD_DATA = \
    {"type"=>"text",
     "group"=>"Inventory",
     "label"=>"User/Typical usage",
     "attribute"=>"user_name",
     "forPackage"=>true,
     "permissions"=>{"role"=>"inventory_manager", "owner"=>true},
     "target_type"=>"item"}

  NEW_DATA = \
    {"type"=>"text",
     "group"=>"Inventory",
     "label"=>"Usage",
     "attribute"=>"usage",
     "forPackage"=>true,
     "permissions"=>{"role"=>"inventory_manager", "owner"=>true},
     "target_type"=>"item"}

  def up
    add_column :items, :usage, :string
    remove_column :items, :user_name

    if old_field = MigrationField.find_by_id('user_name')
      with_disabled_triggers do
        MigrationField.create!(id: 'usage',
                               active: old_field.active?,
                               data: NEW_DATA.to_json,
                               position: old_field.position)
      end
    else
      position = MigrationField.order('position DESC').first.position
      with_disabled_triggers do
        MigrationField.create!(id: 'usage',
                               data: NEW_DATA.to_json,
                               position: position + 1)
      end
    end

    execute <<-SQL
      UPDATE hidden_fields
      SET field_id = 'usage'
      WHERE field_id = 'user_name'
    SQL

    with_disabled_triggers { old_field.try(&:destroy) }
  end

  def down
    add_column :items, :user_name, :string
    remove_column :items, :usage

    old_field = MigrationField.find_by_id('usage')
    ###############################################################################
    # with disabled triggers
    ActiveRecord::Base.connection.execute 'SET session_replication_role = REPLICA;'
    MigrationField.create!(id: 'user_name',
                           active: old_field.active?,
                           data: OLD_DATA.to_json,
                           position: old_field.position)
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
    ###############################################################################

    execute <<-SQL
      UPDATE hidden_fields
      SET field_id = 'user_name'
      WHERE field_id = 'usage'
    SQL

    with_disabled_triggers { old_field.try(&:destroy) }
  end

  def with_disabled_triggers
    ###############################################################################
    # with disabled triggers
    ActiveRecord::Base.connection.execute 'SET session_replication_role = REPLICA;'
    yield
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
    ###############################################################################
  end
end
