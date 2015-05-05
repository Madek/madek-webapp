require 'spec_helper'
require 'spec_helper_integration'

describe 'CreateMetaDatum' do
  before :each do
    @user = FactoryGirl.create :user
    @media_entry = FactoryGirl.create :media_entry
    post session_sign_in_path,
         login: @user.login,
         password: @user.password
  end

  context 'success' do
    it 'MetaDatum::People' do
      meta_key = FactoryGirl.create(:meta_key_people)
      ids = Person.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::People', content: ids }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.people.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Groups' do
      meta_key = FactoryGirl.create(:meta_key_groups)
      ids = Group.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Groups', content: ids }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.groups.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Users' do
      meta_key = FactoryGirl.create(:meta_key_users)
      ids = User.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Users', content: ids }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.users.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Licenses' do
      meta_key = FactoryGirl.create(:meta_key_licenses)
      ids = License.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Licenses', content: ids }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.licenses.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      ids = KeywordTerm.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Keywords', content: ids }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.keywords.map(&:keyword_term).map(&:id))
        .to be == Set.new(ids)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      text = Faker::Lorem.word
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Text', content: text }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(md.value).to be == text
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryGirl.create(:meta_key_text_date)
      text = Faker::Lorem.word
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::TextDate', content: text }
      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(md.value).to be == text
    end

    context 'collection' do
      it 'MetaDatum::Text' do
        meta_key = FactoryGirl.create(:meta_key_text)
        text = Faker::Lorem.word
        collection = FactoryGirl.create :collection
        post meta_data_path(collection),
             collection_id: collection.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Text', content: text }
        assert_response :created
        md = collection.meta_data.find_by_meta_key_id(meta_key.id)
        expect(md).to be
        expect(md.value).to be == text
      end
    end
  end

  context 'failure' do
    it 'meta_key_id & media_entry_id uniqueness' do
      pending 'TODO'
      meta_key = FactoryGirl.create(:meta_key_keywords)
      FactoryGirl.create(:meta_datum_keywords,
                         meta_key: meta_key,
                         media_entry: @media_entry)
      ids = KeywordTerm.take(2).map(&:id)
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Keywords', content: ids }
      assert_response :internal_server_error
      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 1
    end

    it 'unknown meta_datum type' do
      meta_key = \
        FactoryGirl.create(:meta_key,
                           id: "test:#{Faker::Lorem.word}",
                           meta_datum_object_type: 'NonSense')
      post meta_data_path(@media_entry),
           media_entry_id: @media_entry.id,
           _key: meta_key.id,
           _value: { type: 'MetaDatum::Keywords', content: Faker::Lorem.word }
      assert_response :internal_server_error
      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end

    # TODO: should an empty value array be possible to persist?
    # it 'empty value array' do
    #   meta_key = FactoryGirl.create(:meta_key_people)
    #   post meta_data_path(@media_entry),
    #        media_entry_id: @media_entry.id,
    #        _key: meta_key.id,
    #        _value: { type: 'MetaDatum::People', content: [] }
    #   assert_response :internal_server_error
    #   md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
    #   expect(md.count).to be == 0
    # end

    # it 'value array with empty values' do
    #   meta_key = FactoryGirl.create(:meta_key_people)
    #   post meta_data_path(@media_entry),
    #        media_entry_id: @media_entry.id,
    #        _key: meta_key.id,
    #        _value: { type: 'MetaDatum::People', content: ['', ''] }
    #   assert_response :internal_server_error
    #   md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
    #   expect(md.count).to be == 0
    # end
  end
end
