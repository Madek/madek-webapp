require 'spec_helper'

describe Presenters::Previews::Preview do
  let(:entry) { FactoryBot.create(:embed_test_video_entry) }
  let(:preview) { entry.media_file.previews.find_by!(conversion_profile: 'hls') }

  it 'exposes the master url, the zip, and one download per rung' do
    dumped = described_class.new(preview).dump

    expect(dumped[:url]).to include("/media/#{preview.id}/hls/master.m3u8")
    expect(dumped[:download_url]).to include("/media/#{preview.id}/hls.zip")
    expect(dumped[:renditions].map { |rendition| rendition[:height] }).to eq [360, 720, 1080]
    expect(dumped[:renditions].map { |rendition| rendition[:url] }).to all(include('download=yes'))
    expect(dumped[:profile]).to eq 'hls'
  end
end
