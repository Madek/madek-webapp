class CreateVisualization < ActiveRecord::Migration

  def change

    create_table :visualizations, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :resource_identifier, null: false
      t.text :control_settings
      t.text :layout
    end

    add_foreign_key :visualizations, :users, dependent: :destroy
  end


end
