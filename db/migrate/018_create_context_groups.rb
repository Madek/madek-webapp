class CreateContextGroups < ActiveRecord::Migration

  def change
    create_table :context_groups, id: :uuid  do |t|
      t.string :name
      t.index :name, unique: true

      t.integer :position, null: false
      t.index :position
    end
  end

end
