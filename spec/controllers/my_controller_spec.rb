require 'spec_helper'

describe MyController do

  before :example do
    @user = FactoryGirl.create :user
    @limit_for_resources = 6
    @limit_for_groups = 4
    @user.groups << (group = FactoryGirl.create(:group))

    5.times { @user.groups << FactoryGirl.create(:group) }

    10.times { FactoryGirl.create :media_entry, responsible_user: @user }
    10.times { FactoryGirl.create :collection, responsible_user: @user }
    10.times { FactoryGirl.create :filter_set, responsible_user: @user }

    10.times { FactoryGirl.create :media_entry, creator: @user }

    arg_hash = { get_metadata_and_previews: true }
    4.times do
      FactoryGirl.create \
        :media_entry_user_permission,
        arg_hash.merge(user: @user,
                       media_entry: FactoryGirl.create(:media_entry))
    end
    4.times do
      FactoryGirl.create \
        :media_entry_group_permission,
        arg_hash.merge(group: group,
                       media_entry: FactoryGirl.create(:media_entry))
    end

    4.times do
      FactoryGirl.create \
        :collection_user_permission,
        arg_hash.merge(user: @user,
                       collection: FactoryGirl.create(:collection))
    end

    4.times do
      FactoryGirl.create \
        :collection_group_permission,
        arg_hash.merge(group: group,
                       collection: FactoryGirl.create(:collection))
    end

    4.times do
      FactoryGirl.create \
        :filter_set_user_permission,
        arg_hash.merge(user: @user,
                       filter_set: FactoryGirl.create(:filter_set))
    end

    4.times do
      FactoryGirl.create \
        :filter_set_group_permission,
        arg_hash.merge(group: group,
                       filter_set: FactoryGirl.create(:filter_set))
    end

    @user.media_entries.sample(@limit_for_resources + 1)
      .each { |me| me.favor_by @user }
    @user.collections.sample(@limit_for_resources + 1)
      .each { |c| c.favor_by @user }
    @user.filter_sets.sample(@limit_for_resources + 1)
      .each { |fs| fs.favor_by @user }
  end

  it 'dashboard' do
    get :dashboard, nil,  user_id: @user.id
    assert_template :dashboard
    assert_response :success

    get = assigns(:get)
    expect(get.is_a?(Presenter)).to be true
    expect(get.api)
      .to eq [:my_content, :latest_imports, :favorites, :entrusted, :groups]

    # "Meine Inhalte"
    my_content = get.my_content
    expect(my_content[:media_entries].count).to be == @limit_for_resources
    expect(my_content[:media_entries].first.is_a?(Presenter)).to be true
    expect(presented_entity my_content[:media_entries].first)
      .to eq @user.media_entries.reorder('created_at DESC').first

    expect(my_content[:collections].count).to be == @limit_for_resources
    expect(my_content[:collections].first.is_a?(Presenter)).to be true
    expect(presented_entity my_content[:collections].first)
      .to eq @user.collections.reorder('created_at DESC').first

    expect(my_content[:filter_sets].count).to be == @limit_for_resources
    expect(my_content[:filter_sets].first.is_a?(Presenter)).to be true
    expect(presented_entity my_content[:filter_sets].first)
      .to eq @user.filter_sets.reorder('created_at DESC').first

    # "Meine letzten Importe"
    imports = get.latest_imports
    expect(imports.count).to be == @limit_for_resources
    expect(imports.first.is_a?(Presenter)).to be true
    expect(presented_entity imports.first)
      .to eq @user.created_media_entries.reorder('created_at DESC').first

    # "Mir anvertraute Inhalte"
    entrusted = get.entrusted
    expect(entrusted[:media_entries].count).to be == @limit_for_resources
    expect(entrusted[:media_entries].first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted[:media_entries].first)
      .to eq MediaEntry.entrusted_to_user(@user).reorder('created_at DESC').first

    expect(entrusted[:collections].count).to be == @limit_for_resources
    expect(entrusted[:collections].first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted[:collections].first)
      .to eq Collection.entrusted_to_user(@user).reorder('created_at DESC').first

    expect(entrusted[:filter_sets].count).to be == @limit_for_resources
    expect(entrusted[:filter_sets].first.is_a?(Presenter)).to be true
    expect(presented_entity entrusted[:filter_sets].first)
      .to eq FilterSet.entrusted_to_user(@user).reorder('created_at DESC').first

    # "Meine Gruppen"
    groups = get.groups
    expect(groups.count).to be == @limit_for_groups
  end

end

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@resource
end
