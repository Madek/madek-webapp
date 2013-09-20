class CreateZencoderJobs < ActiveRecord::Migration

  def up
    create_table :zencoder_jobs, id: false do |t|
      t.uuid :id, null: false
      t.references :media_file, null: false
      t.integer :zencoder_id
      t.text :comment
      t.string :state, null: false, default: 'initialized'
      t.text :error
      t.text :notification
      t.text :request
      t.text :response
      t.timestamps
    end

    execute "ALTER TABLE zencoder_jobs ADD PRIMARY KEY (id)"

    add_index :zencoder_jobs, :created_at
    add_index :zencoder_jobs, :media_file_id

    add_foreign_key :zencoder_jobs, :media_files

    remove_column :media_files, :job_id
  end



  def down

    change_table(:media_files) do |t| 
      t.string :job_id
    end

    MediaFile.reset_column_information
    ZencoderJob.reset_column_information 

    ZencoderJob.all.each do |zj|
      MediaFile.where(id: zj.media_file_id).first \
        .update_attributes  job_id: zj.zencoder_id.to_s
    end

    drop_table :zencoder_jobs
  end

end
