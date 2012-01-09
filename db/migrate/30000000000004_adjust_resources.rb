class AdjustResources < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    [:media_sets,:media_entries].each do |resource|
      add_column resource, :media_resource_id, :integer, :null => false 
      add_index resource, :media_resource_id
    end

    MediaEntry.all.each do |me| 
      mr = MediaResource.create :owner => me.upload_session.user
      me.media_resource = mr
      me.save!
    end

    Media::Set.all.each do |ms| 
      mr = MediaResource.create :owner => ms.user
      mr.media_resource = mr
      ms.save!
    end

    add_fkey_referrence_constraint MediaEntry, MediaResource
    add_fkey_referrence_constraint Media::Set, MediaResource

  end

  def down

    [:media_sets,:media_entries].each do |resource|
      remove_column resource, :media_resource_id
    end

  end

end
