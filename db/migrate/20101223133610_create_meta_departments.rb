class CreateMetaDepartments < ActiveRecord::Migration
  def self.up
    key = MetaKey.where(:label => "institutional affiliation").first
    if key
      key.update_attributes(:object_type => "MetaDepartment")
      File.open("#{Rails.root}/config/definitions/helpers/old_department_meta_data.yml", 'w') do |f|
        YAML.dump(key.meta_data, f)
      end
      key.meta_data.destroy_all
    end

    create_table :meta_departments do |t|
      t.string :key
      t.string :name
    end
    change_table :meta_departments do |t|
      t.index :key
      t.index :name
    end
  end

  def self.down
    MetaKey.update_all({:object_type => nil}, {:label => "institutional affiliation"})    
    drop_table :meta_departments
  end
end
