require 'spec_helper'

def create_vocabulary_permissions(vocab)
  vocab.user_permissions << \
    FactoryBot.create(:vocabulary_user_permission,
                       user: @user,
                       view: true,
                       use: true)
end

def delete_and_assert_success(meta_datum)
  delete :destroy, params: { id: meta_datum.id }, session: { user_id: @user.id }
  assert_response 303
  expect { MetaDatum.find(meta_datum.id) }
    .to raise_error(ActiveRecord::RecordNotFound)
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

  context 'delete success' do
    it 'MetaDatum::People' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Keywords with RdfClass=License' do
      meta_key = FactoryBot.create(:meta_key_keywords_license)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          keywords: [create(:keyword, :license)],
                          meta_key: meta_key,
                          media_entry: @media_entry)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryBot.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text,
                          meta_key: meta_key,
                          string: Faker::Lorem.word,
                          media_entry: @media_entry)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryBot.create(:meta_key_text_date)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text_date,
                          meta_key: meta_key,
                          string: Date.today.to_s,
                          media_entry: @media_entry)
      delete_and_assert_success(meta_datum)
    end
  end
end
