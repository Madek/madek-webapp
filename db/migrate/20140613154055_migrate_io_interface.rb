class MigrateIoInterface < ActiveRecord::Migration
  def up 

    Context.where(id: 'sq6').each do |c|
      c.update_attributes is_user_interface: true
    end

    Context.where(is_user_interface: false).each do |io_context|
      io_interface_id= io_context.id == 'io_interface' ? 'default' : io_context.id
      io_interface= IoInterface.create! id: io_interface_id, description: io_context.description

      MetaKeyDefinition.where(context_id: io_context.id).each do |mkd|
        IoMapping.create! io_interface_id: io_interface_id, meta_key_id: mkd.meta_key_id,
          key_map: mkd.key_map, key_map_type: mkd.key_map_type
        mkd.destroy
      end

      io_context.destroy
    end

    remove_column :meta_key_definitions, :key_map
    remove_column :meta_key_definitions, :key_map_type
    remove_column :contexts, :is_user_interface

    execute "UPDATE io_interfaces SET id = 'default' where id = 'io_interface'"

  end
end
