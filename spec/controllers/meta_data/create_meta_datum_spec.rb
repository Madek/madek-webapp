require 'spec_helper'

def create_vocabulary_permissions(vocab)
  vocab.user_permissions << \
    FactoryBot.create(:vocabulary_user_permission,
                       user: @user,
                       view: true,
                       use: true)
end

describe MetaDataController do
  before :each do

    @user = FactoryBot.create :user
    @media_entry = FactoryBot.create :media_entry
    @media_entry.user_permissions << \
      FactoryBot.create(:media_entry_user_permission,
                         user: @user,
                         edit_metadata: true)
  end

  context 'create success' do
    it 'MetaDatum::People' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      ids = Person.take(2).map(&:id)
      post :create,
           params: {
             media_entry_id: @media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::People',
             values: ids },
           session: { user_id: @user.id }

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.people.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Keywords with RdfClass=License' do
      meta_key = FactoryBot.create(:meta_key_keywords_license)
      create_vocabulary_permissions(meta_key.vocabulary)
      2.times { FactoryBot.create :keyword, :license, meta_key: meta_key }
      ids = Keyword.where(rdf_class: 'License').take(2).map(&:id)
      post :create,
           params: {
             media_entry_id: @media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::Keywords',
             values: ids },
           session: { user_id: @user.id }

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.keywords.map(&:id)).to be == Set.new(ids)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      2.times { FactoryBot.create :keyword }
      ids = Keyword.take(2).map(&:id)
      post :create,
           params: {
             media_entry_id: @media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::Keywords',
             values: ids },
           session: { user_id: @user.id }

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(Set.new md.keywords.map(&:id))
        .to be == Set.new(ids)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryBot.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
      text = Faker::Lorem.word
      post :create,
           params: {
             media_entry_id: @media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::Text',
             values: [text] },
           session: { user_id: @user.id }

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(md.value).to be == text
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryBot.create(:meta_key_text_date)
      create_vocabulary_permissions(meta_key.vocabulary)
      text = Faker::Lorem.word
      post :create,
           params: {
             media_entry_id: @media_entry.id,
             meta_key: meta_key.id,
             type: 'MetaDatum::TextDate',
             values: [text] },
           session: { user_id: @user.id }

      assert_response :created
      md = @media_entry.meta_data.find_by_meta_key_id(meta_key.id)
      expect(md).to be
      expect(md.value).to be == text
    end

    context 'collection' do
      it 'MetaDatum::Text' do
        meta_key = FactoryBot.create(:meta_key_text)
        create_vocabulary_permissions(meta_key.vocabulary)
        text = Faker::Lorem.word
        collection = FactoryBot.create :collection
        collection.user_permissions << \
          FactoryBot.create(:collection_user_permission,
                             user: @user,
                             edit_metadata_and_relations: true)
        post :create,
             params: {
               collection_id: collection.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::Text',
               values: [text] },
             session: { user_id: @user.id }

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
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = FactoryBot.create(:meta_datum_keywords,
                                      created_by: @user,
                                      meta_key: meta_key,
                                      media_entry: @media_entry)
      ids = meta_datum.keywords.map(&:id)

      expect do
        post :create,
             params: {
               media_entry_id: @media_entry.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::Keywords',
               values: ids },
             session: { user_id: @user.id }
      end.to raise_error ActiveRecord::RecordNotUnique

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 1
    end

    it 'unknown meta_datum type' do
      expect do
        FactoryBot.create(:meta_key,
                           id: "test:#{Faker::Lorem.word}",
                           meta_datum_object_type: 'NonSense')
        create_vocabulary_permissions(meta_key.vocabulary)
      end.to raise_error /check_valid_meta_datum_object_type/
    end

    it 'empty value array' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)

      expect do
        post :create,
             params: {
               media_entry_id: @media_entry.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::People',
               values: [] },
             session: { user_id: @user.id }
      end.to raise_error ActionController::ParameterMissing

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end

    it 'value array with empty values' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)

      expect do
        post :create,
             params: {
               media_entry_id: @media_entry.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::People',
               values: ['', ''] },
             session: { user_id: @user.id }
      end.to raise_error ActionController::ParameterMissing

      md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
      expect(md.count).to be == 0
    end
  end
end
