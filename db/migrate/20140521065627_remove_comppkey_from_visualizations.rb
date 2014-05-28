class RemoveComppkeyFromVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :id, :uuid, null: false, default: 'uuid_generate_v4()'

    reversible do |dir|

      dir.up do
        execute 'ALTER TABLE visualizations ADD PRIMARY KEY (id)'
      end

      dir.down do
        execute 'ALTER TABLE visualizations DROP CONSTRAINT visualizations_pkey'
      end

    end

  end
end
