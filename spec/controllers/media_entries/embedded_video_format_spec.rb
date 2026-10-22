require 'spec_helper'

describe MediaEntriesController, 'embedded video format' do
  let(:user) { FactoryBot.create(:user, settings: { 'video_playback_format' => 'hls' }) }
  let(:entry) { FactoryBot.create(:embed_test_video_entry, creator: user, responsible_user: user) }

  it 'passes the account default into an internal embed' do
    get :embedded, params: { id: entry.id, internalEmbed: 'yes' }, session: { user_id: user.id }

    config = assigns[:get][:embed_config] || assigns[:get]['embed_config']
    value = config[:preferredVideoFormat] || config['preferredVideoFormat']
    expect(value).to eq 'hls'
  end

  it 'leaves external embeds on the player default' do
    get :embedded, params: { id: entry.id }, session: { user_id: user.id }

    config = assigns[:get][:embed_config] || assigns[:get]['embed_config']
    expect(config.key?(:preferredVideoFormat) || config.key?('preferredVideoFormat')).to be false
  end
end
