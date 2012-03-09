class CreateMetaContextGroups < ActiveRecord::Migration
  def change
    create_table :meta_context_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
