class ChangeMediaResourceModel < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    change_table :media_resources do |t| 
      t.index :created_at

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
