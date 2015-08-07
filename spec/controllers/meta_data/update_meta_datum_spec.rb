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

  context 'success' do
    it 'example of one meta datum type' do
      meta_key = FactoryGirl.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_ids = Person.all.sample(2).map(&:id)
      patch :update,
            { id: meta_datum.id,
              media_entry_id: @media_entry.id,
              _key: meta_key.id,
              _value: { type: 'MetaDatum::People', content: new_ids } },
            user_id: @user.id

      assert_response :ok
      expect(Set.new meta_datum.reload.people.map(&:id))
        .to be == Set.new(new_ids)
    end

    context 'update leads to delete of meta_datum' do
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

        assert_response :ok
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

        assert_response :ok
        md = @media_entry.meta_data.find_by(meta_key_id: meta_key.id)
        expect(md).not_to be
      end
    end
  end
end
