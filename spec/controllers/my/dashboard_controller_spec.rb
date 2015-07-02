require 'spec_helper'

describe My::DashboardController do

  before :example do
    @user = FactoryGirl.create :user
    @limit_for_app_resources = 12
    fake_many = 2 * @limit_for_app_resources
    @user.groups << (group = FactoryGirl.create(:group))

    fake_many.times { @user.groups << FactoryGirl.create(:group) }

    fake_many.times { FactoryGirl.create :media_entry, responsible_user: @user }
    fake_many.times { FactoryGirl.create :collection, responsible_user: @user }
    fake_many.times { FactoryGirl.create :filter_set, responsible_user: @user }

    fake_many.times \
      { FactoryGirl.create :media_entry, creator: @user, responsible_user: @user }

    arg_hash = { get_metadata_and_previews: true }
    4.times do
      FactoryGirl.create \
        :media_entry_user_permission,
        arg_hash.merge(user: @user,
                       media_entry: FactoryGirl.create(:media_entry))
    end
    fake_many.times do
      FactoryGirl.create \
        :media_entry_group_permission,
        arg_hash.merge(group: group,
                       media_entry: FactoryGirl.create(:media_entry))
    end

    fake_many.times do
      FactoryGirl.create \
        :collection_user_permission,
        arg_hash.merge(user: @user,
                       collection: FactoryGirl.create(:collection))
    end

    fake_many.times do
      FactoryGirl.create \
        :collection_group_permission,
        arg_hash.merge(group: group,
                       collection: FactoryGirl.create(:collection))
    end

    fake_many.times do
      FactoryGirl.create \
        :filter_set_user_permission,
        arg_hash.merge(user: @user,
                       filter_set: FactoryGirl.create(:filter_set))
    end

    fake_many.times do
      FactoryGirl.create \
        :filter_set_group_permission,
        arg_hash.merge(group: group,
                       filter_set: FactoryGirl.create(:filter_set))
    end

    @user.media_entries.sample(@limit_for_app_resources + 1)
      .each { |me| me.favor_by @user }
    @user.collections.sample(@limit_for_app_resources + 1)
      .each { |c| c.favor_by @user }
    @user.filter_sets.sample(@limit_for_app_resources + 1)
      .each { |fs| fs.favor_by @user }
  end

  it 'dashboard' do
    get :dashboard, { page: 1 }, user_id: @user.id
    assert_template :dashboard
    assert_response :success

    get = assigns(:get)
    expect(get.is_a?(Presenter)).to be true
    expect(get.api.sort)
      .to eq [:content, :latest_imports, :favorites,
              :entrusted_content, :groups, :uuid].sort

    # "Meine Inhalte"
    my_content = get.content
    expect(my_content.media_entries.total_count).to be == @limit_for_app_resources
    expect(my_content.media_entries.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity my_content.media_entries.resources.first)
      .to eq @user.media_entries.reorder('created_at DESC').first

    expect(my_content.collections.total_count).to be == @limit_for_app_resources
    expect(my_content.collections.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity my_content.collections.resources.first)
      .to eq @user.collections.reorder('created_at DESC').first

    expect(my_content.filter_sets.total_count).to be == @limit_for_app_resources
    expect(my_content.filter_sets.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity my_content.filter_sets.resources.first)
      .to eq @user.filter_sets.reorder('created_at DESC').first

    # "Meine letzten Importe"
    imports = get.latest_imports.media_entries
    expect(imports.total_count).to be == @limit_for_app_resources
    expect(imports.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity imports.resources.first)
      .to eq @user.created_media_entries.reorder('created_at DESC').first

    # "Mir anvertraute Inhalte"
    entrusted = get.entrusted_content
    expect(entrusted.media_entries.total_count).to be == @limit_for_app_resources
    expect(entrusted.media_entries.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted.media_entries.resources.first)
      .to eq MediaEntry.entrusted_to_user(@user).reorder('created_at DESC').first

    expect(entrusted.collections.total_count).to be == @limit_for_app_resources
    expect(entrusted.collections.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted.collections.resources.first)
      .to eq Collection.entrusted_to_user(@user).reorder('created_at DESC').first

    expect(entrusted.filter_sets.total_count).to be == @limit_for_app_resources
    expect(entrusted.filter_sets.resources.first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted.filter_sets.resources.first)
      .to eq FilterSet.entrusted_to_user(@user).reorder('created_at DESC').first

    # "Meine Gruppen"
    groups = get.groups
    expect((groups[:internal] + groups[:external])
            .count)
            .to be == @limit_for_app_resources
  end

end

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@app_resource
end
