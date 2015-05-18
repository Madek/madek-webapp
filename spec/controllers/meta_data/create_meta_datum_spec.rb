require 'spec_helper'

describe MetaDataController do
  before :each do
    @user = FactoryGirl.create :user
    @media_entry = FactoryGirl.create :media_entry
  end

  context 'success' do
    it 'MetaDatum::People' do
      meta_key = FactoryGirl.create(:meta_key_people)
      ids = Person.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::People', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.people.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Groups' do
      meta_key = FactoryGirl.create(:meta_key_groups)
      2.times { FactoryGirl.create :group }
      ids = Group.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Groups', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.groups.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Users' do
      meta_key = FactoryGirl.create(:meta_key_users)
      ids = User.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Users', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.users.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Licenses' do
      meta_key = FactoryGirl.create(:meta_key_licenses)
      2.times { FactoryGirl.create :license }
      ids = License.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Licenses', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.licenses.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      2.times { FactoryGirl.create :keyword_term }
      ids = KeywordTerm.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Keywords', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.keywords.map(&:keyword_term).map(&:id))
        .to be == Set.new(ids)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      text = Faker::Lorem.word
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Text', content: [text] } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(md.value).to be == text
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryGirl.create(:meta_key_text_date)
      text = Faker::Lorem.word
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::TextDate', content: [text] } },
           user_id: @user.id

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
        post :create,
             { collection_id: collection.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::Text', content: [text] } },
             user_id: @user.id

        assert_response :created
        md = collection.meta_data.find_by_meta_key_id(meta_key.id)
        expect(md).to be
        expect(md.value).to be == text
      end
    end
  end

  context 'failure' do
    it 'meta_key_id & media_entry_id uniqueness' do
      # example: meta_key_id & media_entry_id uniqueness
      meta_key = FactoryGirl.create(:meta_key_keywords)
      meta_datum = FactoryGirl.create(:meta_datum_keywords,
                                      meta_key: meta_key,
                                      media_entry: @media_entry)
      meta_datum.keyword_terms << FactoryGirl.create(:keyword_term)
      ids = meta_datum.keyword_terms.map(&:id)

      expect do
        post :create,
             { media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::Keywords', content: ids } },
             user_id: @user.id
      end.to raise_error ActiveRecord::RecordNotUnique

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 1
    end

    it 'unknown meta_datum type' do
      meta_key = \
        FactoryGirl.create(:meta_key,
                           id: "test:#{Faker::Lorem.word}",
                           meta_datum_object_type: 'NonSense')

      expect do
        post :create,
             { media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: meta_key.meta_datum_object_type,
                         content: Faker::Lorem.word } },
             user_id: @user.id
      end.to raise_error Errors::InvalidParameterValue

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end

    it 'empty value array' do
      meta_key = FactoryGirl.create(:meta_key_people)

      expect do
        post :create,
             { media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: [] } },
             user_id: @user.id
      end.to raise_error ActionController::ParameterMissing

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end

    it 'value array with empty values' do
      meta_key = FactoryGirl.create(:meta_key_people)

      expect do
        post :create,
             { media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: ['', ''] } },
             user_id: @user.id
      end.to raise_error ActionController::ParameterMissing

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end
  end
end
