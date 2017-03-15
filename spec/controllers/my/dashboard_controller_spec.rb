require 'spec_helper'

describe My::DashboardController do

  before :context do
    @user = FactoryGirl.create :user
    @limit_for_dashboard = 6
    @limit_for_app_resources = 12
    fake_many = 2 * @limit_for_app_resources

    fake_many.times { @user.groups << FactoryGirl.create(:group) }
    group = @user.groups.first
    # FIXME: no factory for InstitutionalGroup in datalayer
    # fake_many.times { @user.groups << FactoryGirl.create(:institutional_group) }

    # Unfinished Uploads:
    fake_many.times do
      FactoryGirl.create :media_entry, is_published: false,
                                       responsible_user: @user, creator: @user
    end

    # Regular Content
    fake_many.times do
      FactoryGirl.create :media_entry,
                         responsible_user: @user
    end
    fake_many.times do
      FactoryGirl.create :collection,
                         responsible_user: @user
    end
    fake_many.times do
      FactoryGirl.create :filter_set,
                         responsible_user: @user
    end

    # Imported Content
    fake_many.times do
      FactoryGirl.create(:media_entry,
                         creator: @user,
                         get_metadata_and_previews: true)
    end

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

    @user.responsible_media_entries.sample(@limit_for_app_resources + 1)
      .each { |me| me.favor_by @user }
    @user.responsible_collections.sample(@limit_for_app_resources + 1)
      .each { |c| c.favor_by @user }
    @user.responsible_filter_sets.sample(@limit_for_app_resources + 1)
      .each { |fs| fs.favor_by @user }

    ##############################################################################
    # make keywords and use them in a meta_datum
    unless @meta_key_core_keywords = MetaKey.find_by_id('madek_core:keywords')
      with_disabled_triggers do
        @meta_key_core_keywords = \
          FactoryGirl.create(:meta_key,
                             id: 'madek_core:keywords',
                             meta_datum_object_type: 'MetaDatum::Keywords')
      end
    end
    @keyword_1 = FactoryGirl.create(:keyword,
                                    meta_key_id: 'madek_core:keywords',
                                    creator: @user)
    @keyword_2 = FactoryGirl.create(:keyword,
                                    meta_key_id: 'madek_core:keywords',
                                    creator: @user)
    @keyword_3 = FactoryGirl.create(:keyword,
                                    meta_key_id: 'madek_core:keywords',
                                    creator: @user)

    unless @meta_key_other_keywords = MetaKey.find_by_id('test:keywords')
      @meta_key_other_keywords = FactoryGirl.create(:meta_key_keywords)
    end

    # create a meta_datum type keywords for a meta_key other than
    # 'madek_core:keywords' and use a keyword there
    # (this should be excluded in the result then)
    keyword_other_meta_key = \
      FactoryGirl.create(:keyword,
                         meta_key: @meta_key_other_keywords,
                         creator: @user)
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_other_keywords),
           created_by: @user,
           created_at: Date.today,
           keyword: keyword_other_meta_key)

    # create a meta_datum type keywords for a unpublished media entries
    # and use a keyword there (this should be excluded in the result then)
    keyword_xxx = \
      FactoryGirl.create(:keyword,
                         meta_key: @meta_key_core_keywords,
                         creator: @user)
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_core_keywords,
                              media_entry: create(:media_entry,
                                                  is_published: false)),
           created_by: @user,
           created_at: Date.today,
           keyword: keyword_xxx)

    # create all other meta_data which should be included in the result
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_core_keywords),
           created_by: @user,
           created_at: Date.today,
           keyword: @keyword_1)
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_core_keywords),
           created_at: Date.yesterday,
           created_by: @user,
           keyword: @keyword_2)
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_core_keywords),
           created_at: Date.today - 1.week,
           created_by: @user,
           keyword: @keyword_3)
    create(:meta_datum_keyword,
           meta_datum: create(:meta_datum_keywords,
                              meta_key: @meta_key_core_keywords),
           created_at: Date.today - 1.week,
           created_by: @user,
           keyword: @keyword_3)
    ##############################################################################
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
      .to eq [
        :activity_stream,
        :unpublished_entries,
        :content_media_entries,
        :dashboard_header,
        :content_collections, :content_filter_sets,
        :latest_imports,
        :favorite_media_entries, :favorite_collections, :favorite_filter_sets,
        :entrusted_media_entries, :entrusted_collections, :entrusted_filter_sets,
        :groups,
        :used_keywords,
        :action,
        :clipboard,
        :_presenter].sort
  end

  describe 'sections' do

    it 'Unpublished Entries' do
      unpublished = @get.unpublished_entries
      expect(unpublished.resources.length)
        .to be == @limit_for_dashboard
      expect(unpublished.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity unpublished.resources.first)
        .to eq @user.unpublished_media_entries.reorder('created_at DESC').first

    end

    it 'Meine Inhalte' do
      my = @get
      expect(my.content_media_entries.resources.length)
        .to be == @limit_for_dashboard
      expect(my.content_media_entries.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my.content_media_entries.resources.first)
        .to eq @user.responsible_media_entries.reorder('created_at DESC').first

      expect(my.content_collections.resources.length)
        .to be == @limit_for_dashboard
      expect(my.content_collections.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my.content_collections.resources.first)
        .to eq @user.responsible_collections.reorder('created_at DESC').first

      expect(my.content_filter_sets.resources.length)
        .to be == @limit_for_dashboard
      expect(my.content_filter_sets.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity my.content_filter_sets.resources.first)
        .to eq @user.responsible_filter_sets.reorder('created_at DESC').first
    end

    it 'Meine letzten Importe' do
      imports = @get.latest_imports
      expect(imports.resources.length).to be == @limit_for_dashboard
      expect(imports.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity imports.resources.first)
        .to eq @user.created_media_entries.reorder('created_at DESC').first
    end

    it 'Meine Schlagworte' do
      # TODO: move to model and/or integration test
      expect(@get.used_keywords.map(&:uuid))
        .to match_array [@keyword_1, @keyword_2, @keyword_3].map(&:id)
    end

    it 'Mir anvertraute Inhalte' do
      my = @get
      expect(my.entrusted_media_entries.resources.length)
        .to be == @limit_for_dashboard
      expect(my.entrusted_media_entries.resources.first.is_a?(Presenter)).to be
      expect(presented_entity my.entrusted_media_entries.resources.first)
        .to eq MediaEntry.entrusted_to_user(@user).reorder('created_at DESC').first

      expect(my.entrusted_collections.resources.length)
        .to be == @limit_for_dashboard
      expect(my.entrusted_collections.resources.first.is_a?(Presenter)).to be
      expect(presented_entity my.entrusted_collections.resources.first)
        .to eq Collection.entrusted_to_user(@user).reorder('created_at DESC').first

      expect(my.entrusted_filter_sets.resources.length)
        .to be == @limit_for_dashboard
      expect(my.entrusted_filter_sets.resources.first.is_a?(Presenter)).to be
      expect(presented_entity my.entrusted_filter_sets.resources.first)
        .to eq FilterSet.entrusted_to_user(@user).reorder('created_at DESC').first
    end

    it 'Meine Gruppen' do
      groups = @get.groups
      expect(groups[:internal].count).to be == 20
    end
  end

end

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@app_resource
end
