require 'spec_helper'

describe MyController do

  # NOTE: should be moved to presenter test
  #
  # before :example do
  #   @user = FactoryGirl.create :user
  #   @limit_for_resources = 6
  #   @limit_for_groups = 4
  #   @user.groups << (group = FactoryGirl.create(:group))

  #   5.times { @user.groups << FactoryGirl.create(:group) }

  #   10.times { FactoryGirl.create :media_entry, responsible_user: @user }
  #   10.times { FactoryGirl.create :collection, responsible_user: @user }
  #   10.times { FactoryGirl.create :filter_set, responsible_user: @user }

  #   10.times { FactoryGirl.create :media_entry, creator: @user }

  #   arg_hash = { get_metadata_and_previews: true }
  #   4.times do
  #     FactoryGirl.create \
  #       :media_entry_user_permission,
  #       arg_hash.merge(user: @user,
  #                      media_entry: FactoryGirl.create(:media_entry))
  #   end
  #   4.times do
  #     FactoryGirl.create \
  #       :media_entry_group_permission,
  #       arg_hash.merge(group: group,
  #                      media_entry: FactoryGirl.create(:media_entry))
  #   end

  #   4.times do
  #     FactoryGirl.create \
  #       :collection_user_permission,
  #       arg_hash.merge(user: @user,
  #                      collection: FactoryGirl.create(:collection))
  #   end

  #   4.times do
  #     FactoryGirl.create \
  #       :collection_group_permission,
  #       arg_hash.merge(group: group,
  #                      collection: FactoryGirl.create(:collection))
  #   end

  #   4.times do
  #     FactoryGirl.create \
  #       :filter_set_user_permission,
  #       arg_hash.merge(user: @user,
  #                      filter_set: FactoryGirl.create(:filter_set))
  #   end

  #   4.times do
  #     FactoryGirl.create \
  #       :filter_set_group_permission,
  #       arg_hash.merge(group: group,
  #                      filter_set: FactoryGirl.create(:filter_set))
  #   end

  #   @user.media_entries.sample(@limit_for_resources + 1)
  #     .each { |me| me.favor_by @user }
  #   @user.collections.sample(@limit_for_resources + 1)
  #     .each { |c| c.favor_by @user }
  #   @user.filter_sets.sample(@limit_for_resources + 1)
  #     .each { |fs| fs.favor_by @user }
  # end

  # it 'dashboard' do
  #   get :dashboard, nil,  user_id: @user.id
  #   assert_template :dashboard
  #   assert_response :success

  #   latest_media_entries = assigns(:latest_media_entries)
  #   expect(latest_media_entries.count).to be == @limit_for_resources
  #   expect(latest_media_entries.first)
  #     .to eq @user.media_entries.reorder('created_at DESC').first

  #   latest_collections = assigns(:latest_collections)
  #   expect(latest_collections.count).to be == @limit_for_resources
  #   expect(latest_collections.first)
  #     .to eq @user.collections.reorder('created_at DESC').first

  #   latest_filter_sets = assigns(:latest_filter_sets)
  #   expect(latest_filter_sets.count).to be == @limit_for_resources
  #   expect(latest_filter_sets.first)
  #     .to eq @user.filter_sets.reorder('created_at DESC').first

  #   latest_imports = assigns(:latest_imports)
  #   expect(latest_imports.count).to be == @limit_for_resources
  #   expect(latest_imports.first)
  #     .to eq @user.created_media_entries.reorder('created_at DESC').first

  #   entrusted_media_entries = assigns(:entrusted_media_entries)
  #   expect(entrusted_media_entries.count).to be == @limit_for_resources
  #   expect(entrusted_media_entries.first)
  #     .to eq MediaEntry.entrusted_to_user(@user).reorder('created_at DESC').first

  #   entrusted_collections = assigns(:entrusted_collections)
  #   expect(entrusted_collections.count).to be == @limit_for_resources
  #   expect(entrusted_collections.first)
  #     .to eq Collection.entrusted_to_user(@user).reorder('created_at DESC').first

  #   entrusted_filter_sets = assigns(:entrusted_filter_sets)
  #   expect(entrusted_filter_sets.count).to be == @limit_for_resources
  #   expect(entrusted_filter_sets.first)
  #     .to eq FilterSet.entrusted_to_user(@user).reorder('created_at DESC').first

  #   groups = assigns(:groups)
  #   expect(groups.count).to be == @limit_for_groups
  # end

end
