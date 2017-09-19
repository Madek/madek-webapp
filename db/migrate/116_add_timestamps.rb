class AddTimestamps < ActiveRecord::Migration[5.0]


  class ::MigrationProcurementBudgetPeriods < ActiveRecord::Base
    self.table_name = 'procurement_budget_periods'
  end

  class ::MigrationProcurementRequests < ActiveRecord::Base
    self.table_name = 'procurement_requests'
  end


  def change
    [:procurement_requests, :procurement_budget_periods].each do |table|
      klass = "migration_#{table}".classify.pluralize.constantize

      add_column table, :updated_at, :datetime

      klass.all.each do |i|
        i.update_attributes!(updated_at: i.created_at)
      end

      execute "ALTER TABLE #{table} ALTER COLUMN updated_at SET DEFAULT now()"
      execute "ALTER TABLE #{table} ALTER COLUMN updated_at SET NOT NULL"
    end
  end

end
