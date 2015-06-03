require 'spec_helper'

def create_vocabulary_permissions(vocab)
  vocab.user_permissions << \
    FactoryGirl.create(:vocabulary_user_permission,
                       user: @user,
                       view: true,
                       use: true)
end

def delete_and_assert_success(meta_datum)
  delete :destroy, { id: meta_datum.id }, user_id: @user.id
  assert_response :ok
  expect { MetaDatum.find(meta_datum.id) }.to raise_error
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
      original_ids = Person.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::People.create!(media_entry_id: @media_entry.id,
                                  meta_key_id: meta_key.id,
                                  value: original_ids)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Users' do
      meta_key = FactoryGirl.create(:meta_key_users)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_ids = User.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Users.create!(media_entry_id: @media_entry.id,
                                 meta_key_id: meta_key.id,
                                 value: original_ids)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Groups' do
      meta_key = FactoryGirl.create(:meta_key_groups)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_ids = Group.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Groups.create!(media_entry_id: @media_entry.id,
                                  meta_key_id: meta_key.id,
                                  value: original_ids)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Licenses' do
      meta_key = FactoryGirl.create(:meta_key_licenses)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_ids = License.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Licenses.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_ids = KeywordTerm.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Keywords.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_text = Faker::Lorem.word
      meta_datum = \
        MetaDatum::Text.create!(media_entry_id: @media_entry.id,
                                meta_key_id: meta_key.id,
                                value: original_text)
      delete_and_assert_success(meta_datum)
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryGirl.create(:meta_key_text_date)
      create_vocabulary_permissions(meta_key.vocabulary)
      original_text_date = Faker::Lorem.word
      meta_datum = \
        MetaDatum::TextDate.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_text_date)
      delete_and_assert_success(meta_datum)
    end
  end
end
