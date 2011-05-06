class AddPositionToMetaTermsMetaKeys < ActiveRecord::Migration
  def self.up
    add_column :meta_keys_meta_terms, :id, :primary_key
    change_table :meta_keys_meta_terms do |t|
      t.integer :position, :null => false, :default => 0
      t.index :position
    end
  end

  def self.down
    change_table :meta_keys_meta_terms do |t|
      t.remove :id
      t.remove :position
    end
  end
end
