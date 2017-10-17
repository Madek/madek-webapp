class CreateOrdersTables < ActiveRecord::Migration[5.0]
  def up
    create_table :orders, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :inventory_pool_id, null: false
      t.text :purpose
      t.text :state, null: false
      t.timestamps null: false, default: -> { 'NOW()' }
    end

    order_states = %w(submitted approved rejected)

    execute <<-SQL
      ALTER TABLE orders
      ADD CONSTRAINT check_valid_state
      CHECK (state IN (#{order_states.map{|s|"'#{s}'"}.join(', ')}))
    SQL
  end

  def down
    drop_table :orders
  end
end
