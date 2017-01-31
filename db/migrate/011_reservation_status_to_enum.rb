class ReservationStatusToEnum < ActiveRecord::Migration
  def change
    add_column :partitions, :position, :int, default: 0, null: false
    execute <<-SQL.strip_heredoc
      ALTER TABLE reservations DROP CONSTRAINT check_allowed_statuses;
      CREATE TYPE reservation_status AS ENUM  ('unsubmitted', 'submitted', 'rejected', 'approved', 'signed', 'closed');
      ALTER TABLE reservations ALTER COLUMN status TYPE reservation_status USING status::reservation_status;
    SQL
  end
end
