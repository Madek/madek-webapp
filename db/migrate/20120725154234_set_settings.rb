class SetSettings < ActiveRecord::Migration
  def change

    change_table :media_resource_arcs do |t|
      t.boolean :cover
      t.index :cover
    end
  
    change_table :media_resources do |t|
      t.string :settings
    end
  
  end
end
