require 'spec_helper'

describe LocalHlsEncoder do
  let(:media_file) { create :media_file_for_movie, guid: SecureRandom.hex }
  let(:fixture) do
    Madek::Constants::DATALAYER_ROOT_DIR.join(
      'spec', 'data', 'embed_test_files', 'originals', 'c', 'cb8c0a46f2744c3891ff5bd893581d21'
    )
  end

  before do
    skip 'ffmpeg/ffprobe not installed' unless described_class.available?
    FileUtils.mkdir_p(File.dirname(media_file.original_store_location))
    FileUtils.cp(fixture, media_file.original_store_location)
  end

  it 'stores an HLS package and a progressive mp4 preview' do
    described_class.new(media_file, progressive: true).call

    hls = media_file.previews.find_by!(conversion_profile: 'hls')
    expect(hls.media_type).to eq 'video'
    expect(File.file?(File.join(HlsPackage.new(media_file).dir, 'master.m3u8'))).to be true
    expect(HlsPackage.new(media_file).renditions.map { |rendition| rendition[:height] }).to include(360)

    mp4 = media_file.previews.find_by!(conversion_profile: 'mp4')
    expect(mp4.content_type).to eq 'video/mp4'
    expect(mp4.width).to eq 620
    expect(File.file?(mp4.file_path)).to be true
  end
end
