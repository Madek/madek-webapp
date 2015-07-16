require 'spec_helper'

def create_vocabulary_permissions(vocab)
  vocab.user_permissions << \
    FactoryGirl.create(:vocabulary_user_permission,
                       user: @user,
                       view: true,
                       use: true)
end

describe MetaDataController do
  before :each do
    @user = FactoryGirl.create :user
    @media_entry = FactoryGirl.create :media_entry
    @media_entry.user_permissions << \
      FactoryGirl.create(:media_entry_user_permission,
                         user: @user,
                         edit_metadata: true)
  end

  context 'success' do
    it 'MetaDatum::People' do
      meta_key = FactoryGirl.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
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
      create_vocabulary_permissions(meta_key.vocabulary)
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
      create_vocabulary_permissions(meta_key.vocabulary)
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
      create_vocabulary_permissions(meta_key.vocabulary)
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
      create_vocabulary_permissions(meta_key.vocabulary)
      2.times { FactoryGirl.create :keyword }
      ids = Keyword.take(2).map(&:id)
      post :create,
           { media_entry_id: @media_entry.id,
             _key: meta_key.id,
             _value: { type: 'MetaDatum::Keywords', content: ids } },
           user_id: @user.id

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.keywords.map(&:id))
        .to be == Set.new(ids)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
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
      create_vocabulary_permissions(meta_key.vocabulary)
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
        create_vocabulary_permissions(meta_key.vocabulary)
        text = Faker::Lorem.word
        collection = FactoryGirl.create :collection
        collection.user_permissions << \
          FactoryGirl.create(:collection_user_permission,
                             user: @user,
                             edit_metadata_and_relations: true)
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
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = FactoryGirl.create(:meta_datum_keywords,
                                      meta_key: meta_key,
                                      media_entry: @media_entry)
      meta_datum.keywords << FactoryGirl.create(:keyword)
      ids = meta_datum.keywords.map(&:id)

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
      expect do
        FactoryGirl.create(:meta_key,
                           id: "test:#{Faker::Lorem.word}",
                           meta_datum_object_type: 'NonSense')
        create_vocabulary_permissions(meta_key.vocabulary)
      end.to raise_error /check_valid_meta_datum_object_type/
    end

    it 'empty value array' do
      meta_key = FactoryGirl.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)

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
      create_vocabulary_permissions(meta_key.vocabulary)

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
