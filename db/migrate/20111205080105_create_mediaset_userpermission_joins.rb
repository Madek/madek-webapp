
class CreateMediasetUserpermissionJoins < ActiveRecord::Migration
  include MigrationHelpers

  MigrationHelpers.patch_index_name()


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

  end


  def down
    [Media::Set, MediaEntry].each do |resource_model|
      [Userpermission, Grouppermission].each do |permission_model|

        table_name = "#{resource_model.table_name}_#{permission_model.table_name}_joins"

        drop_del_referenced_trigger table_name, permission_model
        drop_del_referenced_trigger table_name, resource_model
        drop_table table_name

      end
    end


  end
end
