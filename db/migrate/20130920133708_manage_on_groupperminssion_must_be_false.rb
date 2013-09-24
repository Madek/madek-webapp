class ManageOnGroupperminssionMustBeFalse < ActiveRecord::Migration
  def up
    execute "UPDATE grouppermissions SET manage = false;"
    execute "ALTER TABLE grouppermissions ADD CONSTRAINT manage_on_grouppermissions_is_false CHECK (manage = false); "
  end

  def down
     execute "ALTER TABLE grouppermissions DROP CONSTRAINT manage_on_grouppermissions_is_false ;"
  end
end
