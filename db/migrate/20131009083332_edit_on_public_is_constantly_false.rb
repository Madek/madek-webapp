class EditOnPublicIsConstantlyFalse < ActiveRecord::Migration
  def up
    execute "UPDATE media_resources SET edit = false;"
    execute "ALTER TABLE media_resources ADD CONSTRAINT edit_on_publicpermissions_is_false CHECK (edit = false); "
  end

  def down
     execute "ALTER TABLE media_resources DROP CONSTRAINT edit_on_publicpermissions_is_false ;"
  end
end
