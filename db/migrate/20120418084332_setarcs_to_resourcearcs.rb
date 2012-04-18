class SetarcsToResourcearcs < ActiveRecord::Migration
  include SQLHelper

  def up
    rename_table :media_set_arcs,  :media_resource_arcs
    execute "ALTER SEQUENCE media_set_arcs_id_seq  RENAME TO media_resource_arcs_id_seq ;" if adapter_is_postgresql?
  end

  def down
    rename_table :media_resource_arcs, :media_set_arcs
    execute "ALTER SEQUENCE media_resource_arcs_id_seq RENAME TO media_set_arcs_id_seq ;" if adapter_is_postgresql?
  end

end
