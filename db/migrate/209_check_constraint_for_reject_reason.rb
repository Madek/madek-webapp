class CheckConstraintForRejectReason < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT check_state_and_reject_reason_consistency CHECK (
        (state IN ('submitted', 'approved', 'rejected') AND reject_reason IS NULL) OR
        (state = 'rejected' AND reject_reason IS NOT NULL)
      )
    SQL
  end

  def down
    execute 'ALTER TABLE orders DROP CONSTRAINT check_state_and_reject_reason_consistency'
  end
end
