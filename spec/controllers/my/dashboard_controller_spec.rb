require 'spec_helper'

describe My::DashboardController do

  before :context do
    @user = FactoryGirl.create :user
    @limit_for_dashboard = 6
    @limit_for_app_resources = 12
    fake_many = 2 * @limit_for_app_resources
    @user.groups << (group = FactoryGirl.create(:group))

    fake_many.times { @user.groups << FactoryGirl.create(:group) }

    # Unfinished Uploads:
    fake_many.times do
      FactoryGirl.create :media_entry, is_published: false,
                                       responsible_user: @user, creator: @user
    end

    # Regular Content
    fake_many.times do
      FactoryGirl.create :media_entry,
                         responsible_user: @user, creator: @user
    end
    fake_many.times do
      FactoryGirl.create :collection,
                         responsible_user: @user, creator: @user
    end
    fake_many.times do
      FactoryGirl.create :filter_set,
                         responsible_user: @user, creator: @user
    end

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

  before :example do
    get :dashboard, { page: 1 }, user_id: @user.id
    @get = assigns(:get)
  end

  it 'renders correctly' do
    assert_template :dashboard
    assert_response :success
  end

  it 'has correct presenter' do
    expect(@get.is_a?(Presenter)).to be true
    expect(@get.api.sort)
      .to eq [:unpublished, :content, :latest_imports, :favorites,
              :entrusted_content, :groups, :used_keywords, :uuid].sort
  end

  describe 'sections' do

    it 'Unpublished Entries' do
      unpublished = @get.unpublished.media_entries
      expect(unpublished.resources.length)
        .to be == @limit_for_dashboard
      expect(unpublished.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity unpublished.resources.first)
        .to eq @user.unpublished_media_entries.reorder('created_at DESC').first

    end

    it 'Meine Inhalte' do
      my_content = @get.content
      expect(my_content.media_entries.resources.length)
        .to be == @limit_for_dashboard
      expect(my_content.media_entries.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my_content.media_entries.resources.first)
        .to eq @user.media_entries.reorder('created_at DESC').first

      expect(my_content.collections.resources.length)
        .to be == @limit_for_dashboard
      expect(my_content.collections.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my_content.collections.resources.first)
        .to eq @user.collections.reorder('created_at DESC').first

      expect(my_content.filter_sets.resources.length)
        .to be == @limit_for_dashboard
      expect(my_content.filter_sets.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my_content.filter_sets.resources.first)
        .to eq @user.filter_sets.reorder('created_at DESC').first
    end

    it 'Meine letzten Importe' do
      imports = @get.latest_imports.media_entries
      expect(imports.resources.length).to be == @limit_for_dashboard
      expect(imports.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity imports.resources.first)
        .to eq @user.published_media_entries.reorder('created_at DESC').first
    end

    it 'Mir anvertraute Inhalte' do
      entrusted = @get.entrusted_content
      expect(entrusted.media_entries.resources.length)
        .to be == @limit_for_dashboard
      expect(entrusted.media_entries.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity entrusted.media_entries.resources.first)
        .to eq MediaEntry.entrusted_to_user(@user).reorder('created_at DESC').first

      expect(entrusted.collections.resources.length)
        .to be == @limit_for_dashboard
      expect(entrusted.collections.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity entrusted.collections.resources.first)
        .to eq Collection.entrusted_to_user(@user).reorder('created_at DESC').first

      expect(entrusted.filter_sets.resources.length)
        .to be == @limit_for_dashboard
      expect(entrusted.filter_sets.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity entrusted.filter_sets.resources.first)
        .to eq FilterSet.entrusted_to_user(@user).reorder('created_at DESC').first
    end

    it 'Meine Gruppen' do
      groups = @get.groups
      expect((groups[:internal] + groups[:external])
              .count)
              .to be == @limit_for_dashboard
    end
  end

end

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@app_resource
end
