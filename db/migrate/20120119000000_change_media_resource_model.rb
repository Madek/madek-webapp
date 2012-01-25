class ChangeMediaResourceModel < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    change_table :media_resources do |t| 

      drop_not_null_constraint MediaResource, :type, "varchar(255)"

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
