class AddReservationsOrderIdConstraint < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      ALTER TABLE reservations
      ADD CONSTRAINT check_order_id_for_different_statuses_of_item_line
      CHECK ((type = 'ItemLine' AND
              ((status = 'unsubmitted' AND order_id IS NULL) OR
               (status IN ('submitted', 'rejected') AND order_id IS NOT NULL) OR
               (status IN ('approved', 'signed', 'closed')))) OR
             (type = 'OptionLine' AND status IN ('approved', 'signed', 'closed')))
    SQL
  end

  def down
    execute 'ALTER TABLE reservations DROP CONSTRAINT check_order_id_for_different_statuses_of_item_line'
  end
end
