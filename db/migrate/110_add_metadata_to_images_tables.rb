class AddMetadataToImagesTables < ActiveRecord::Migration[4.2]
  TABLES = [:images,
            :attachments,
            :procurement_images,
            :procurement_attachments]

  class MigrationImages < ActiveRecord::Base
    self.table_name = 'images'
  end

  class MigrationAttachments < ActiveRecord::Base
    self.table_name = 'attachments'
  end

  class MigrationProcurementImages < ActiveRecord::Base
    self.table_name = 'procurement_images'
  end

  class MigrationProcurementAttachments < ActiveRecord::Base
    self.table_name = 'procurement_attachments'
  end

  def up
    TABLES.each do |table|
      add_column table, :metadata, :json
    end

    tmp_dir = `mktemp -d`.chomp

    puts '###################################'
    puts 'TABLE: images'
    puts '###################################'
    MigrationImages.all.each do |entity|
      read_and_store_metadata(entity, tmp_dir)
    end
    puts '###################################'
    puts 'TABLE: attachments'
    puts '###################################'
    MigrationAttachments.all.each do |entity|
      read_and_store_metadata(entity, tmp_dir)
    end
    puts '###################################'
    puts 'TABLE: procurement_images'
    puts '###################################'
    MigrationProcurementImages.all.each do |entity|
      read_and_store_metadata(entity, tmp_dir)
    end
    puts '###################################'
    puts 'TABLE: procurement_attachments'
    puts '###################################'
    MigrationProcurementAttachments.all.each do |entity|
      read_and_store_metadata(entity, tmp_dir)
    end
  end

  def down
    TABLES.each do |table|
      remove_column table, :metadata
    end
  end

  def read_and_store_metadata(entity, tmp_dir)
    puts "#{entity.class.table_name}: #{entity.id} - #{entity.filename}"
    if entity.content.presence
      path = "#{tmp_dir}/#{entity.filename}"
      f = File.new(path, 'w')
      f.write(Base64.decode64(entity.content).force_encoding('UTF-8'))
      f.close
      h = ::MetadataExtractor.new(path).to_hash
      entity.update_attributes!(metadata: h)
      File.delete(path)
    else
      puts "No content!"
    end
  end
end
