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

  context 'update OK' do
    it 'replace MetaDatum::Text' do
      meta_key = FactoryBot.create(:meta_key_text)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_text = Faker::Lorem.sentence

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::Text',
              values: [new_text] },
            session: { user_id: @user.id }

      assert_response 303
      expect(meta_datum.reload.string).to eq new_text
    end

    it 'replace MetaDatum::TextDate' do
      meta_key = FactoryBot.create(:meta_key_text_date)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_text_date,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_text_date = Faker::Lorem.words.join(' ')

      patch :update,
            params: { id: meta_datum.id,
                      media_entry_id: @media_entry.id,
                      meta_key: meta_key.id,
                      type: 'MetaDatum::TextDate',
                      values: [new_text_date] },
            session: { user_id: @user.id }

      assert_response 303
      expect(meta_datum.reload.string).to eq new_text_date
    end

    it 'MetaDatum::People: assign one (keep existing assignments)' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_people_ids = \
        meta_datum.people.map(&:id) + [FactoryBot.create(:person).id]

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::People', values: new_people_ids },
            session: { user_id: @user.id }

      assert_response 303
      expect(meta_datum.reload.people.map(&:id))
        .to match_array new_people_ids
    end

    it 'MetaDatum::People: assign one (replace existing assignments)' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_people_ids = [FactoryBot.create(:person).id]

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::People',
              values: new_people_ids
            },
            session: { user_id: @user.id }

      assert_response 303

      expect(meta_datum.reload.people.map(&:id))
        .to match_array new_people_ids
      expect(meta_datum.people.first.creator_id).to be_nil
    end

    it 'MetaDatum::People, create person' do
      meta_key = FactoryBot.create(:meta_key_people)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      patch :update, 
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::People',
              values: [{first_name: 'Ping', last_name: 'Pong'}]
            },
            session: { user_id: @user.id }
                        
      assert_response 303

      p = meta_datum.reload.people.first
      expect(p.first_name).to eq 'Ping'
      expect(p.last_name).to eq 'Pong'
      expect(p.creator_id).to eq @user.id
    end

    it 'MetaDatum::People: assign people and roles (and create role)' do
      meta_key = FactoryBot.create(:meta_key_people_with_roles)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_people,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_role = FactoryBot.create(:role, roles_lists: [meta_key.roles_list],
                                   labels: { de: 'Nitai', en: 'Nitai' })
      new_person = FactoryBot.create(:person)

      new_role_2_term = { term: 'Sweeper' }
      new_person_2 = FactoryBot.create(:person)
      new_person_3 = FactoryBot.create(:person)

      patch(:update,
            params: { id: meta_datum.id,
                      media_entry_id: @media_entry.id,
                      meta_key: meta_key.id,
                      type: 'MetaDatum::People',
                      values: [{ uuid: new_person.id, role: new_role.id },
                               { uuid: new_person_2.id, role: new_role_2_term },
                               { uuid: new_person_3.id, role: new_role_2_term }] },
            session: { user_id: @user.id })

      assert_response 303

      expect(meta_datum.reload.meta_data_people.map(&:role_id))
        .to match_array [new_role.id,
                         Role.find { |r| r.labels['en'] == new_role_2_term[:term] }.id,
                         Role.find { |r| r.labels['en'] == new_role_2_term[:term] }.id]
      expect(meta_datum.reload.meta_data_people.map(&:person_id))
        .to match_array [new_person.id, new_person_2.id, new_person_3.id]
    end

    it 'add MetaDatum::Keywords' do
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_keyword_ids = \
        meta_datum.keywords.map(&:id) + [FactoryBot.create(:keyword).id]

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::Keywords', values: new_keyword_ids },
            session: { user_id: @user.id }

      assert_response 303
      expect(meta_datum.reload.keywords.map(&:id))
        .to match_array new_keyword_ids
    end

    it 'add NEW MetaDatum::Keywords' do
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_keyword_data = { term: 'On the fly' }

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::Keywords',
              values: [new_keyword_data] },
            session: { user_id: @user.id }

      assert_response 303
      newly_created_keyword = Keyword.find_by(term: new_keyword_data[:term])
      expect(newly_created_keyword.persisted?).to be true
      expect(meta_datum.reload.keywords.map(&:id))
        .to match_array [newly_created_keyword.id]
    end

    it 'replace MetaDatum::Keywords' do
      meta_key = FactoryBot.create(:meta_key_keywords)
      create_vocabulary_permissions(meta_key.vocabulary)
      meta_datum = create(:meta_datum_keywords,
                          meta_key: meta_key,
                          media_entry: @media_entry)

      new_keyword_ids = [FactoryBot.create(:keyword).id]

      patch :update,
            params: {
              id: meta_datum.id,
              media_entry_id: @media_entry.id,
              meta_key: meta_key.id,
              type: 'MetaDatum::Keywords', values: new_keyword_ids },
            session: { user_id: @user.id }

      assert_response 303
      expect(meta_datum.reload.keywords.map(&:id))
        .to match_array new_keyword_ids
    end

    context 'empty update deletes meta_datum' do
      it 'empty value array' do
        meta_key = FactoryBot.create(:meta_key_people)
        create_vocabulary_permissions(meta_key.vocabulary)
        meta_datum = create(:meta_datum_people,
                            meta_key: meta_key,
                            media_entry: @media_entry)
        post :update,
             params: {
               id: meta_datum.id,
               media_entry_id: @media_entry.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::People',
               values: [] },
             session: { user_id: @user.id }

        assert_response 303
        md = @media_entry.meta_data.find_by(meta_key_id: meta_key.id)
        expect(md).not_to be
      end

      it 'value array with empty values' do
        meta_key = FactoryBot.create(:meta_key_people)
        create_vocabulary_permissions(meta_key.vocabulary)
        meta_datum = create(:meta_datum_people,
                            meta_key: meta_key,
                            media_entry: @media_entry)
        post :update,
             params: {
               id: meta_datum.id,
               media_entry_id: @media_entry.id,
               meta_key: meta_key.id,
               type: 'MetaDatum::People',
               values: ['', ''] },
             session: { user_id: @user.id }

        assert_response 303
        md = @media_entry.meta_data.find_by(meta_key_id: meta_key.id)
        expect(md).not_to be
      end
    end
  end
end
