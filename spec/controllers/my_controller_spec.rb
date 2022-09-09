require 'spec_helper'

describe MyController do

  it 'renders correctly' do
    create_data
    open_dashboard
    assert_template :dashboard
    assert_response :success
  end

  it 'has correct presenter' do
    create_data
    open_dashboard
    expect(@get.is_a?(Presenter)).to be true
    expect(@get.user_dashboard.api.sort)
      .to eq [
        :activity_stream,
        :unpublished_entries,
        :content_media_entries,
        :content_delegated_media_entries,
        :dashboard_header,
        :content_collections,
        :content_delegated_collections,
        :latest_imports,
        :favorite_media_entries, :favorite_collections,
        :entrusted_media_entries, :entrusted_collections,
        :groups_and_delegations,
        :used_keywords,
        :action,
        :tokens,
        :workflows,
        :_presenter].sort
  end

  describe 'sections' do

    it 'Unpublished Entries' do
      create_data
      open_dashboard_section(:unpublished_entries)

      unpublished = @get.user_dashboard.unpublished_entries
      expect(unpublished.resources.length)
        .to be == @limit_for_dashboard
      expect(unpublished.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity unpublished.resources.first)
        .to eq @user.unpublished_media_entries.reorder('created_at DESC').first

    end

    it 'Meine Inhalte' do
      create_data
      open_dashboard_section(:content_media_entries)

      my = @get.user_dashboard
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

    end

    it 'Meine letzten Importe' do
      create_data
      open_dashboard_section(:latest_imports)

      imports = @get.user_dashboard.latest_imports
      expect(imports.resources.length).to be == @limit_for_dashboard
      expect(imports.resources.first.is_a?(Presenter)).to be true
      expect(presented_entity imports.resources.first)
        .to eq @user.created_media_entries.reorder('created_at DESC').first
    end

    it 'Meine Schlagworte' do
      create_data
      open_dashboard_section(:used_keywords)

      # TODO: move to model and/or integration test
      expect(@get.user_dashboard.used_keywords.map(&:uuid))
        .to match_array [@keyword_1, @keyword_2, @keyword_3].map(&:id)
    end

    it 'Mir anvertraute Inhalte' do
      create_data
      open_dashboard_section(:entrusted_media_entries)

      my = @get.user_dashboard
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

    end

    it 'Meine Gruppen' do
      create_data
      open_dashboard_section(:groups)

      groups = @get.user_dashboard.groups_and_delegations
      expect(groups[:internal].count).to be == 20
    end
  end
end

private

# hackish way to get the resource of a decorator - API in progress
def presented_entity(presenter)
  presenter.instance_variable_get :@app_resource
end

def open_dashboard
  get(
    :dashboard,
    params: {
      page: 1
    },
    session: { user_id: @user.id }
  )
  @get = assigns(:get)
end

def open_dashboard_section(dashboard_section)
  get(
    :dashboard,
    params: {
      page: 1,
      ___sparse: {
        user_dashboard: {
          dashboard_section => {}
        }
      }.to_json
    },
    session: { user_id: @user.id }
  )
  @get = assigns(:get)
end

# rubocop:disable Metrics/MethodLength
def create_data
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

  @user.responsible_media_entries.sample(@limit_for_app_resources + 1)
    .each { |me| me.favor_by @user }
  @user.responsible_collections.sample(@limit_for_app_resources + 1)
    .each { |c| c.favor_by @user }

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
# rubocop:enable Metrics/MethodLength
