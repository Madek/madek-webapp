class CreateProcurementTables < ActiveRecord::Migration
  def up

    create_table :procurement_budget_periods, id: :uuid do |t|
      t.string :name,                 null: false
      t.date :inspection_start_date,  null: false
      t.date :end_date,               null: false, index: true

      t.datetime :created_at,         null: false
    end

    create_table :procurement_groups, id: :uuid do |t|
      t.string :name
      t.string :email
    end

    create_table :procurement_budget_limits, id: :uuid do |t|
      t.uuid :budget_period_id
      t.uuid :group_id
      t.integer :amount_cents, default: 0, null: false
      t.string :amount_currency, default: 'CHF', null: false

      t.index [:budget_period_id, :group_id], unique: true, name: :idx_procurement_budget_limits_bpg
    end
    add_foreign_key(:procurement_budget_limits, :procurement_budget_periods, column: 'budget_period_id')
    add_foreign_key(:procurement_budget_limits, :procurement_groups, column: 'group_id')

    create_table :procurement_group_inspectors, id: :uuid do |t|
      t.uuid :user_id, foreign_key: true
      t.uuid :group_id

      t.index [:user_id, :group_id], unique: true
    end
    add_foreign_key(:procurement_group_inspectors, :procurement_groups, column: 'group_id')

    create_table :procurement_organizations, id: :uuid do |t|
      t.string :name
      t.string :shortname
      t.uuid :parent_id
    end
    add_foreign_key(:procurement_organizations, :procurement_organizations, column: 'parent_id')

    create_table :procurement_accesses, id: :uuid do |t|
      t.uuid :user_id, foreign_key: true
      t.uuid :organization_id, null: true
      t.boolean :is_admin,          index: true
    end
    add_foreign_key(:procurement_accesses, :procurement_organizations, column: 'organization_id')

    create_table :procurement_template_categories, id: :uuid do |t|
      t.uuid :group_id
      t.string :name

      t.index [:group_id, :name], unique: true
    end
    add_foreign_key(:procurement_template_categories, :procurement_groups, column: 'group_id')

    create_table :procurement_templates, id: :uuid do |t|
      t.uuid :template_category_id
      t.uuid :model_id, foreign_key: true
      t.uuid :supplier_id, foreign_key: true
      t.string :article_name, null: false
      t.string :article_number,        null: true
      t.monetize :price
      t.string :supplier_name
    end
    add_foreign_key(:procurement_templates, :procurement_template_categories, column: 'template_category_id')

    create_table :procurement_requests, id: :uuid do |t|
      t.uuid :budget_period_id
      t.uuid :group_id
      t.uuid :user_id, foreign_key: true
      t.uuid :organization_id
      t.uuid :model_id, foreign_key: true
      t.uuid :supplier_id, foreign_key: true
      t.uuid :location_id, foreign_key: true
      t.uuid :template_id
      t.string :article_name,          null: false
      t.string :article_number,        null: true
      t.integer :requested_quantity,   null: false
      t.integer :approved_quantity,    null: true
      t.integer :order_quantity,       null: true
      t.monetize :price
      t.string :priority,              default: 'normal', null: false
      t.boolean :replacement,          default: true
      t.string :supplier_name
      t.string :receiver,              null: true
      t.string :location_name,              null: true
      t.string :motivation,            null: true
      t.string :inspection_comment,    null: true

      t.datetime :created_at,       null: false
    end

    execute <<-SQL.strip_heredoc
      ALTER TABLE procurement_requests
        ADD CONSTRAINT check_allowed_priorities
        CHECK (
          priority IN ('normal', 'high')
        );
    SQL


    add_foreign_key(:procurement_requests, :procurement_budget_periods, column: 'budget_period_id')
    add_foreign_key(:procurement_requests, :procurement_groups, column: 'group_id')
    add_foreign_key(:procurement_requests, :procurement_organizations, column: 'organization_id')
    add_foreign_key(:procurement_requests, :procurement_templates, column: 'template_id')

    create_table :procurement_attachments, id: :uuid do |t|
      t.uuid :request_id
      t.attachment :file
    end
    add_foreign_key(:procurement_attachments, :procurement_requests, column: 'request_id')

  end
end
