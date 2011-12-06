class CreateMediasetUserpermissionJoins < ActiveRecord::Migration
  include MigrationHelpers

  def up

    #TODO check relations ho, hm ...
    #TODO extend to grouppermissions
    %w{media_set media_entry}.each do |resource|

      create_table "#{resource}_userpermission_joins" do |t|
        t.references :userpermission, :null => false
        t.integer "#{resource}_id", :null => false
      end

      add_index "#{resource}_userpermission_joins", :userpermission_id
      add_index "#{resource}_userpermission_joins", "#{resource}_id"
      fkey_cascade_on_delete "#{resource}_userpermission_joins", :userpermission_id, :userpermissions
      fkey_cascade_on_delete "#{resource}_userpermission_joins", "#{resource}_id", "#{resource.pluralize}"

    end

  end

  def down
    %w{media_set media_entry}.each do |resource|
      drop_table "#{resource}_userpermission_joins"
    end
  end

end
