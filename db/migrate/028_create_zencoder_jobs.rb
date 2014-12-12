class CreateZencoderJobs < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :zencoder_jobs, id: :uuid do |t|
      t.uuid :media_file_id, null: false
      t.index :media_file_id

      t.integer :zencoder_id
      t.text :comment
      t.string :state, null: false, default: 'initialized'
      t.text :error
      t.text :notification
      t.text :request
      t.text :response

      t.timestamps null: false
      t.index :created_at
    end

    add_foreign_key :zencoder_jobs, :media_files

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :zencoder_jobs
      end
    end
  end

end
