class CleanMetaDataDuplicates < ActiveRecord::Migration
  def change

    MetaDatum.select(:meta_key_id,:media_resource_id) \
      .group(:meta_key_id,:media_resource_id).having(" count(*) >= 2 ").each do |mdg|
      mda= MetaDatum.where(meta_key_id: mdg.meta_key_id, media_resource_id: mdg.media_resource_id).to_a
      mda.shift
      mda.each{ |md| md.delete }
    end

    add_index :meta_data, [:media_resource_id, :meta_key_id], unique: true


  end
end
