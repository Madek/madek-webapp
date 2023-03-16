require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Section labels' do
  let(:meta_key) { create(:meta_key_keywords, id: "test:sections") }
  let(:app_setting) { AppSetting.first.presence || create(:app_setting) }
  let(:keywords) do
    [
      k1 = create(:keyword, :with_section, meta_key: meta_key, term: 'Karakal'),
      k2 = create(:keyword, :with_section, meta_key: meta_key, term: 'Jaguar'),
      k3 = create(:keyword, meta_key: meta_key, term: 'Section not configured')
    ]
  end

  before { app_setting.update!(section_meta_key_id: meta_key.id) }

  scenario 'are shown on collection and media entry detail view' do
    prepare_user(admin: true)
    login

    collection = create_collection('Test Collection')
    create(:meta_datum_keywords, collection: collection, meta_key: meta_key, keywords: keywords)

    visit collection_path(collection)
    expect(all('div[data-test-id=section-labels] > *').map(&:text)).to eq %w[Jaguar Karakal]

    media_entry = create_media_entry('Test Entry')
    create(:meta_datum_keywords, media_entry: media_entry, meta_key: meta_key, keywords: keywords)

    visit media_entry_path(media_entry)
    expect(all('div[data-test-id=section-labels] > *').map(&:text)).to eq %w[Jaguar Karakal]
  end
end
