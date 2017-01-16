class ProcurementInspectorPriorityColumn < ActiveRecord::Migration
  def up
    add_column :procurement_requests, :inspector_priority, :string, null: false, default: 'medium'

    execute <<-SQL.strip_heredoc
      ALTER TABLE procurement_requests
        ADD CONSTRAINT check_inspector_priority
        CHECK (
          inspector_priority IN ('low', 'medium', 'high', 'mandatory')
        );
    SQL
  end
end
