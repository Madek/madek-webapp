class FlattenMetaNs < ActiveRecord::Migration

  def up
    MetaKey.where("object_type like 'Meta::%' ").each do |mk|
      mk.object_type = mk.object_type.gsub /^Meta::/, "Meta"
      mk.save!
    end
  end

  def down
  end

end
