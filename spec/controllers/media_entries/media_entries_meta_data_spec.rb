require 'spec_helper'

describe MediaEntriesController do
  before :example do
    @user = create(:user)
  end

  context 'multiple meta_data update' do
    before :example do
      @media_entry = create(:media_entry)
      @media_entry.user_permissions << \
        create(:media_entry_user_permission,
               user: @user,
               edit_metadata: true)
      @vocab = create(:vocabulary)
      @media_entry.meta_data << \
        create(:meta_datum_text,
               meta_key_id: create(:meta_key_text,
                                   id: "#{@vocab.id}:mk_text").id,
               string: 'original_value')
      @media_entry.meta_data << \
        create(:meta_datum_keywords,
               meta_key_id: create(:meta_key_keywords,
                                   id: "#{@vocab.id}:mk_keywords").id,
               keywords: [(@keyword = create(:keyword))])

      @new_keyword = create(:keyword)
    end

    it 'success' do
      xhr :put,
          :meta_data_update,
          { id: @media_entry.id,
            media_entry: {
              meta_data: { "#{@vocab.id}:mk_text" => ['test title'],
                           "#{@vocab.id}:mk_keywords" => [@new_keyword.id] }
            },
            format: :json
          },
          user_id: @user.id

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body['meta_data']).not_to be_empty
      @media_entry.reload
      expect(
        @media_entry
          .meta_data
          .find_by_meta_key_id("#{@vocab.id}:mk_text")
          .value
      ).to be == 'test title'
      expect(
        @media_entry
          .meta_data
          .find_by_meta_key_id("#{@vocab.id}:mk_keywords")
          .value
      ).to be == [@new_keyword]
    end

    it 'error' do
      unknown_keyword_id = UUIDTools::UUID.random_create.to_s

      xhr :put,
          :meta_data_update,
          { id: @media_entry.id,
            media_entry: {
              meta_data: { "#{@vocab.id}:mk_text" => ['test title'],
                           "#{@vocab.id}:mk_keywords" => [unknown_keyword_id],
                           'unknown_key' => ['bla'] }
            },
            format: :json
          },
          user_id: @user.id

      expect(response.status).to be == 400
      body = JSON.parse(response.body)
      expect(body['errors'].size).to be == 2
      @media_entry.reload
      expect(
        @media_entry
          .meta_data
          .find_by_meta_key_id("#{@vocab.id}:mk_text")
          .value
      ).to be == 'original_value'
      expect(
        @media_entry
          .meta_data
          .find_by_meta_key_id("#{@vocab.id}:mk_keywords")
          .value
      ).to be == [@keyword]
      expect(@media_entry.meta_data.find_by_meta_key_id('unknown_key')).not_to be
    end
  end
end
