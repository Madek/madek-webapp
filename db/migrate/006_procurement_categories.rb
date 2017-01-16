class ProcurementCategories < ActiveRecord::Migration
  def up

    remove_foreign_key(:procurement_templates, column: 'template_category_id')
    change_table :procurement_templates do |t|
      t.remove :template_category_id
    end

    drop_table :procurement_template_categories
    create_table :procurement_main_categories, id: :uuid do |t|
      t.string :name
      t.attachment :image

      t.index :name, unique: true
    end
    create_table :procurement_categories, id: :uuid do |t|
      t.string :name
      t.uuid :main_category_id, null: true

      t.index :name, unique: true
      t.index :main_category_id
    end

    drop_table :procurement_group_inspectors
    create_table :procurement_category_inspectors, id: :uuid do |t|
      t.uuid :user_id, null: false, foreign_key: true
      t.uuid :category_id, null: false

      t.index [:user_id, :category_id], unique: true, name: :idx_procurement_group_inspectors_uc
    end
    add_foreign_key(:procurement_category_inspectors, :procurement_categories, column: 'category_id')


    drop_table :procurement_budget_limits
    create_table :procurement_budget_limits, id: :uuid do |t|
      t.uuid :budget_period_id, null: false
      t.uuid :main_category_id, null: false
      t.monetize :amount

      t.index [:budget_period_id, :main_category_id], unique: true, name: 'index_on_budget_period_id_and_category_id'
    end
    add_foreign_key(:procurement_budget_limits, :procurement_budget_periods, column: 'budget_period_id')
    add_foreign_key(:procurement_budget_limits, :procurement_main_categories, column: 'main_category_id')


    remove_foreign_key(:procurement_requests, column: 'group_id')
    rename_column(:procurement_requests, :group_id, :category_id)
    change_column_null :procurement_requests, :category_id, false
    add_foreign_key(:procurement_requests, :procurement_categories, column: 'category_id')


    change_table :procurement_templates do |t|
      t.uuid :category_id, null: false
    end
    add_foreign_key(:procurement_templates, :procurement_categories, column: 'category_id')


    drop_table :procurement_groups

  end
end
