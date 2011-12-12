class DagToDg < ActiveRecord::Migration
  def up

    create_table :setset_arcs do |t|
      t.integer :parent_id
      t.integer :child_id
    end


  end

  def down
    drop_table :setset_arcs
  end

end
