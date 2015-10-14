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
      @keyword = create(:keyword)
      @new_keyword = create(:keyword)
      @meta_key_keywords = create(:meta_key_keywords,
                                  id: "#{@vocab.id}:mk_keywords").id
      @meta_key_text = create(:meta_key_text,
                              id: "#{@vocab.id}:mk_text").id
      @unused_meta_key_text = create(:meta_key_text,
                                     id: "#{@vocab.id}:unused_text").id
      @unused_meta_key_people = create(:meta_key_people,
                                       id: "#{@vocab.id}:unused_people").id
      @unused_meta_key_keywords = create(:meta_key_keywords,
                                         id: "#{@vocab.id}:unused_keywords").id
      @media_entry.meta_data << \
        create(:meta_datum_text,
               meta_key_id: @meta_key_text, string: 'original_value')
    end

    it 'create & update success' do
      # there is no MetaDatum for this MetaKey yet, create it on the fly:
      put_meta_data(
        @meta_key_keywords => [@new_keyword.id],
        @meta_key_text => ['test title'],
        # also send along some blank data like the client
        @unused_meta_key_text => [],
        @unused_meta_key_people => [],
        @unused_meta_key_keywords => [])

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body['meta_data']).not_to be_empty
      @media_entry.reload
      expect(md_text(@media_entry)).to be == 'test title'
      expect(md_keywords(@media_entry)).to be == [@new_keyword]
    end

    it 'update success' do
      # add a MetaDatumKeyword
      add_meta_datum_keywords
      # change that MetaDatumKeyword to a new Keyword
      put_meta_data(
        "#{@vocab.id}:mk_text" => ['another test title'],
        @meta_key_keywords => [@new_keyword.id],
        # also send along some blank data like the client:
        @unused_meta_key_text => [],
        @unused_meta_key_people => [],
        @unused_meta_key_keywords => []
      )

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body['meta_data']).not_to be_empty
      @media_entry.reload
      expect(md_text(@media_entry)).to be == 'another test title'
      expect(md_keywords(@media_entry)).to be == [@new_keyword]
    end

    it 'update error' do
      unknown_keyword_id = UUIDTools::UUID.random_create.to_s

      add_meta_datum_keywords
      put_meta_data(
        "#{@vocab.id}:mk_text" => ['test title'],
        @meta_key_keywords => [unknown_keyword_id],
        'unknown_key' => ['bla']
      )

      expect(response.status).to be == 400
      body = JSON.parse(response.body)
      expect(body['errors'].size).to be == 2

      @media_entry.reload
      expect(md_text(@media_entry)).to be == 'original_value'
      expect(
        @media_entry
          .meta_data
          .find_by_meta_key_id(@meta_key_keywords)
          .value
      ).to be == [@keyword]
      expect(@media_entry.meta_data.find_by_meta_key_id('unknown_key')).not_to be
    end
  end
end

def md_text(media_entry)
  media_entry.meta_data
    .find_by_meta_key_id(@meta_key_text)
    .value
end

def md_keywords(media_entry)
  media_entry.meta_data
    .find_by_meta_key_id(@meta_key_keywords)
    .value
end

def add_meta_datum_keywords
  @media_entry.meta_data << \
    create(:meta_datum_keywords,
           meta_key_id: @meta_key_keywords,
           keywords: [@keyword])
end

def put_meta_data(data)
  xhr :put,
      :meta_data_update,
      { id: @media_entry.id,
        media_entry: { meta_data: data },
        format: :json
      },
      user_id: @user.id
end
