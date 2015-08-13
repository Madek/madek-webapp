require 'spec_helper'
require 'spec_helper_no_tx'

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

  context 'update OK' do
    it 'replace MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_text = Faker::Lorem.sentence

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::Text', content: new_text } },
            user_id: @user.id

      assert_response 303
      expect(meta_datum.reload.string).to eq new_text
    end

    it 'replace MetaDatum::TextDate' do
      meta_key = FactoryGirl.create(:meta_key_text_date)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text_date,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_text_date = Faker::Lorem.words.join(' ')

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::TextDate', content: new_text_date } },
            user_id: @user.id

      assert_response 303
      expect(meta_datum.reload.string).to eq new_text_date
    end

    it 'add MetaDatum::People' do
      meta_key = FactoryGirl.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_people_ids = \
        meta_datum.people.map(&:id) + [FactoryGirl.create(:person).id]

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::People',
                        content: new_people_ids } },
            user_id: @user.id

      assert_response 303
      expect(meta_datum.reload.people.map(&:id))
        .to match_array new_people_ids
    end

    it 'replace MetaDatum::People' do
      meta_key = FactoryGirl.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_people_ids = [FactoryGirl.create(:person).id]

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::People',
                        content: new_people_ids } },
            user_id: @user.id

      assert_response 303

      expect(meta_datum.reload.people.map(&:id))
        .to match_array new_people_ids
    end

    it 'add MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_keyword_ids = \
        meta_datum.keywords.map(&:id) + [FactoryGirl.create(:keyword).id]

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::Keywords',
                        content: new_keyword_ids } },
            user_id: @user.id

      assert_response 303
      expect(meta_datum.reload.keywords.map(&:id))
        .to match_array new_keyword_ids
    end

    it 'replace MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_keyword_ids = [FactoryGirl.create(:keyword).id]

      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::Keywords',
                        content: new_keyword_ids } },
            user_id: @user.id

      assert_response 303
      expect(meta_datum.reload.keywords.map(&:id))
        .to match_array new_keyword_ids
    end

    context 'empty update deletes meta_datum' do
      it 'empty value array' do
        meta_key = FactoryGirl.create(:meta_key_people)
        create_vocabulary_permissions(meta_key.vocabulary)
        meta_datum = create(:meta_datum_people,
                            meta_key: meta_key,
                            media_entry: @media_entry)
        post :update,
             { id: meta_datum.id,
               media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: [] } },
             user_id: @user.id

        assert_response 303
        md = @media_entry.meta_data.find_by(meta_key_id: meta_key.id)
        expect(md).not_to be
      end

      it 'value array with empty values' do
        meta_key = FactoryGirl.create(:meta_key_people)
        create_vocabulary_permissions(meta_key.vocabulary)
        meta_datum = create(:meta_datum_people,
                            meta_key: meta_key,
                            media_entry: @media_entry)
        post :update,
             { id: meta_datum.id,
               media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: ['', ''] } },
             user_id: @user.id

        assert_response 303
        md = @media_entry.meta_data.find_by(meta_key_id: meta_key.id)
        expect(md).not_to be
      end
    end
  end
end
