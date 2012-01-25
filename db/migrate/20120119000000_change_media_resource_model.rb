class ChangeMediaResourceModel < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    change_table :media_resources do |t| 

      execute_sql "ALTER TABLE media_resources ALTER COLUMN type DROP NOT NULL;"

      Actions.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end
    
  end

  def down

    change_table :media_resources do |t| 
      Actions.each do |action|
        t.remove action
      end
    end

  end

end
