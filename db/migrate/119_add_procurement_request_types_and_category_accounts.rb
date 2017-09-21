class AddProcurementRequestTypesAndCategoryAccounts < ActiveRecord::Migration[5.0]

  def change
    # category.general_ledger_account
    add_column :procurement_categories, :general_ledger_account,
      :string, default: nil, null: true

    # category.cost_center
    add_column :procurement_categories, :cost_center,
      :string, default: nil, null: true

    # request.accounting_type
    accounting_types = %w(aquisition investment)

    add_column :procurement_requests, :accounting_type,
      :string, default: accounting_types.first, null: false

    execute <<-SQL.strip_heredoc
      ALTER TABLE procurement_requests
      ADD CONSTRAINT check_valid_accounting_type
      CHECK (accounting_type IN (#{accounting_types.map{|s|"'#{s}'"}.join(', ')}))
    SQL

    # request.internal_order_number
    add_column :procurement_requests, :internal_order_number,
      :string, default: nil, null: true

    execute <<-SQL.strip_heredoc
      ALTER TABLE procurement_requests
      ADD CONSTRAINT check_internal_order_number_if_type_investment
      CHECK ( NOT (accounting_type = 'investment' AND internal_order_number IS NULL) )
    SQL

  end

end
