class CreateMediasetUserpermissionJoins < ActiveRecord::Migration
  include MigrationHelpers

  def up

    [Media::Set, MediaEntry].each do |resource_model|
      [Userpermission, Grouppermission].each do |permission_model|

        table_name = "#{resource_model.table_name}_#{permission_model.table_name}_joins"

        create_table table_name do |t|
          t.integer ref_id(resource_model), :null => false
          t.integer ref_id(permission_model), :null => false
        end

      add_index table_name, ref_id(resource_model)
      add_index table_name, ref_id(permission_model)

      create_del_referenced_trigger table_name, permission_model
      create_del_referenced_trigger table_name, resource_model


      end
    end


#    #TODO check relations ho, hm ...
#    #TODO extend to grouppermissions
#    %w{media_set media_entry}.each do |resource|
#      create_table "#{resource}_userpermission_joins" do |t|
#        t.references :userpermission, :null => false
#        t.integer "#{resource}_id", :null => false
#      end
#
#      add_index "#{resource}_userpermission_joins", :userpermission_id
#      add_index "#{resource}_userpermission_joins", "#{resource}_id"
#      fkey_cascade_on_delete "#{resource}_userpermission_joins", :userpermission_id, :userpermissions
#      fkey_cascade_on_delete "#{resource}_userpermission_joins", "#{resource}_id", "#{resource.pluralize}"

  end

#    create_del_referenced_trigger MediaEntryUserpermissionJoin, Userpermission
#    create_del_referenced_trigger MediaSetUserpermissionJoin, Userpermission


  def down
    %w{media_set media_entry}.each do |resource|
      drop_table "#{resource}_userpermission_joins"
    end

    [MediaSetUserpermissionJoin, MediaSetUserpermissionJoin].each do |permission_join|
      #drop_del_referenced_trigger permission_join, Userpermission
    end 

  end
end
