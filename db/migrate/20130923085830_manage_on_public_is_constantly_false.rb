class ManageOnPublicIsConstantlyFalse < ActiveRecord::Migration
  def up
    execute "UPDATE media_resources SET manage = false;"
    execute "ALTER TABLE media_resources ADD CONSTRAINT manage_on_publicpermissions_is_false CHECK (manage = false); "
  end

  def down
     execute "ALTER TABLE media_resources DROP CONSTRAINT manage_on_publicpermissions_is_false ;"
  end
end
