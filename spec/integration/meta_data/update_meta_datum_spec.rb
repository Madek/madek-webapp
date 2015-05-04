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
      original_ids = Person.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::People.create!(media_entry_id: @media_entry.id,
                                  meta_key_id: meta_key.id,
                                  value: original_ids)

      new_ids = Person.all.sample(2).map(&:id)
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::People', content: new_ids }
      assert_response :ok
      expect(Set.new meta_datum.reload.people.map(&:id))
        .to be == Set.new(new_ids)
    end

    it 'MetaDatum::Users' do
      meta_key = FactoryGirl.create(:meta_key_users)
      original_ids = User.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Users.create!(media_entry_id: @media_entry.id,
                                 meta_key_id: meta_key.id,
                                 value: original_ids)

      new_ids = User.all.sample(2).map(&:id)
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::Users', content: new_ids }
      assert_response :ok
      expect(Set.new meta_datum.reload.users.map(&:id))
        .to be == Set.new(new_ids)
    end

    it 'MetaDatum::Groups' do
      meta_key = FactoryGirl.create(:meta_key_groups)
      original_ids = Group.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Groups.create!(media_entry_id: @media_entry.id,
                                  meta_key_id: meta_key.id,
                                  value: original_ids)

      new_ids = Group.all.sample(2).map(&:id)
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::Groups', content: new_ids }
      assert_response :ok
      expect(Set.new meta_datum.reload.groups.map(&:id))
        .to be == Set.new(new_ids)
    end

    it 'MetaDatum::Licenses' do
      meta_key = FactoryGirl.create(:meta_key_licenses)
      original_ids = License.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Licenses.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)

      new_ids = License.all.sample(2).map(&:id)
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::Licenses', content: new_ids }
      assert_response :ok
      expect(Set.new meta_datum.reload.licenses.map(&:id))
        .to be == Set.new(new_ids)
    end

    it 'MetaDatum::Keywords' do
      meta_key = FactoryGirl.create(:meta_key_keywords)
      original_ids = KeywordTerm.all.sample(2).map(&:id)
      meta_datum = \
        MetaDatum::Keywords.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_ids)

      new_ids = KeywordTerm.all.sample(2).map(&:id)
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::Keywords', content: new_ids }
      assert_response :ok
      expect(Set.new meta_datum.reload.keyword_terms.map(&:id))
        .to be == Set.new(new_ids)
    end

    it 'MetaDatum::Text' do
      meta_key = FactoryGirl.create(:meta_key_text)
      original_text = Faker::Lorem.word
      meta_datum = \
        MetaDatum::Text.create!(media_entry_id: @media_entry.id,
                                meta_key_id: meta_key.id,
                                value: original_text)

      new_text = Faker::Lorem.word
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::Text', content: new_text }
      assert_response :ok
      expect(meta_datum.reload.value).to be == new_text
    end

    it 'MetaDatum::TextDate' do
      meta_key = FactoryGirl.create(:meta_key_text_date)
      original_text_date = Faker::Lorem.word
      meta_datum = \
        MetaDatum::TextDate.create!(media_entry_id: @media_entry.id,
                                    meta_key_id: meta_key.id,
                                    value: original_text_date)

      new_text_date = Faker::Lorem.word
      patch meta_datum_path(meta_datum),
            media_entry_id: @media_entry.id,
            _key: meta_key.id,
            _value: { type: 'MetaDatum::TextDate', content: new_text_date }
      assert_response :ok
      expect(meta_datum.reload.value).to be == new_text_date
    end
  end
end
