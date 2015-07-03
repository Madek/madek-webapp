require 'spec_helper'

describe My::DashboardController do

  before :example do
    @user = FactoryGirl.create :user
    @resources_limit_dashboard = 6
    @resources_limit_section = 12
    fake_many = 2 * @resources_limit_section
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

    @user.media_entries.sample(@resources_limit_section + 1)
      .each { |me| me.favor_by @user }
    @user.collections.sample(@resources_limit_section + 1)
      .each { |c| c.favor_by @user }
    @user.filter_sets.sample(@resources_limit_section + 1)
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
    expect(my_content.media_resources.count).to be == @resources_limit_dashboard
    expect(my_content.media_resources.all? { |mr| mr.is_a?(Presenter) }).to be true
    expect(presented_entity my_content.media_resources.first)
      .to eq @user.media_resources.reorder('created_at DESC').first

    # "Meine letzten Importe"
    imports = get.latest_imports
    expect(imports.media_resources.count).to be == @resources_limit_dashboard
    expect(presented_entity imports.media_resources.first)
      .to eq @user.created_media_entries.reorder('created_at DESC').first

    # "Mir anvertraute Inhalte"
    entrusted = get.entrusted_content
    expect(entrusted.media_resources.count).to be == @resources_limit_dashboard
    expect(presented_entity entrusted.media_resources.first)
      .to eq MediaResource.entrusted_to_user(@user)
              .reorder('created_at DESC').first

    # "Meine Gruppen"
    groups = get.groups
    expect((groups[:internal] + groups[:external])
            .count)
            .to be == @resources_limit_dashboard
  end

end

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@app_resource
end
