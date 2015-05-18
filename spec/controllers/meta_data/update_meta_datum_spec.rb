require 'spec_helper'

describe MetaDataController do
  before :each do
    @user = FactoryGirl.create :user
    @media_entry = FactoryGirl.create :media_entry
  end

  context 'success' do
    it 'example of one meta datum type' do
      meta_key = FactoryGirl.create(:meta_key_people)
      original_ids = Person.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::People.create!(media_entry_id: @media_entry.id,
                                  meta_key_id: meta_key.id,
                                  value: original_ids)

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
        original_ids = Person.all.sample(2).map(&:id)
        meta_datum = \
          MetaDatum::People.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)
        post :update,
             { id: meta_datum.id,
               media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: [] } },
             user_id: @user.id

        assert_response :ok
        md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
        expect(md.count).to be == 1
      end

      it 'value array with empty values' do
        meta_key = FactoryGirl.create(:meta_key_people)
        original_ids = Person.all.sample(2).map(&:id)
        meta_datum = \
          MetaDatum::People.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)
        post :update,
             { id: meta_datum.id,
               media_entry_id: @media_entry.id,
               _key: meta_key.id,
               _value: { type: 'MetaDatum::People', content: ['', ''] } },
             user_id: @user.id

        assert_response :ok
        md = @media_entry.meta_data.where(meta_key_id: meta_key.id)
        expect(md.count).to be == 1
      end
    end
  end
end
