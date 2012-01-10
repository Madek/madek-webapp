class CreatePermissionsets < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up
    create_table :permissionsets do |t|

      # REMARK if we ever go to a tripple state: consider to remove
      #   the not null constraint and use that for "unset";
      # however, check how that would work out with the sql queries 

      Actions.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end

    Actions.each do |action|
      add_index :permissionsets, action
    end

  end

  def down
    drop_table :permissionsets
  end

end
