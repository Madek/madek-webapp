require 'spec_helper'
require 'zip'

describe ZencoderHlsImport, webmock: true do
  let(:media_file) { create :media_file_for_movie, guid: SecureRandom.hex }
  let(:hls_dir) { HlsPackage.new(media_file).dir }

  def zip_of(files)
    buffer = Zip::OutputStream.write_buffer do |out|
      files.each do |name, body|
        out.put_next_entry(name)
        out.write(body)
      end
    end
    buffer.string
  end

  def variant(media, iframes: false)
    <<~M3U8
      #EXTM3U
      #EXT-X-VERSION:7
      #EXT-X-TARGETDURATION:6
      #EXT-X-PLAYLIST-TYPE:VOD
      #{'#EXT-X-I-FRAMES-ONLY' if iframes}
      #EXT-X-MAP:URI="#{media}",BYTERANGE="10@0"
      #EXTINF:6.0,
      #EXT-X-BYTERANGE:20@10
      #{media}
      #EXT-X-ENDLIST
    M3U8
  end

  let(:master) do
    <<~M3U8
      #EXTM3U
      #EXT-X-VERSION:7
      #EXT-X-STREAM-INF:BANDWIDTH=1000000,RESOLUTION=640x360
      360.m3u8
      #EXT-X-STREAM-INF:BANDWIDTH=3200000,RESOLUTION=1280x720
      720.m3u8
      #EXT-X-STREAM-INF:BANDWIDTH=6200000,RESOLUTION=1920x1080
      1080.m3u8
      #EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=100000,URI="360-iframe-index.m3u8"
    M3U8
  end

  def output(label, url, state: 'finished')
    { 'label' => label, 'state' => state, 'url' => url }
  end

  context 'with one zip per rung and a plain master playlist' do
    let(:outputs) do
      [
        output('hls_360', 'https://zc.example/o/1/abc.profile_hls_360.zip'),
        output('hls_720', 'https://zc.example/o/1/abc.profile_hls_720.zip'),
        output('hls_1080', nil, state: 'skipped'),
        output('hls', 'https://zc.example/o/1/abc.profile_hls.m3u8')
      ]
    end

    before do
      %w[360 720].each do |rung|
        stub_request(:get, "https://zc.example/o/1/abc.profile_hls_#{rung}.zip").to_return(
          body: zip_of(
            "abc.profile_hls_#{rung}.m3u8" => variant("abc.profile_hls_#{rung}.mp4"),
            "abc.profile_hls_#{rung}-iframe-index.m3u8" => variant("abc.profile_hls_#{rung}.mp4", iframes: true),
            "abc.profile_hls_#{rung}.mp4" => 'media-bytes-' * 4
          )
        )
      end
      stub_request(:get, 'https://zc.example/o/1/abc.profile_hls.m3u8').to_return(body: master)
    end

    it 'stores renamed rungs and drops the skipped rung from the master' do
      described_class.new(media_file, outputs).call

      expect(Dir.children(hls_dir)).to match_array(
        %w[master.m3u8 360.m3u8 360.mp4 360-iframe-index.m3u8 720.m3u8 720.mp4 720-iframe-index.m3u8]
      )
      expect(File.read(File.join(hls_dir, '360.m3u8'))).to include('URI="360.mp4"')
      expect(File.read(File.join(hls_dir, '360.m3u8'))).to include("\n360.mp4\n")
      expect(File.read(File.join(hls_dir, '720-iframe-index.m3u8'))).to include('#EXT-X-I-FRAMES-ONLY')

      master_text = File.read(File.join(hls_dir, 'master.m3u8'))
      expect(master_text).to include("360.m3u8\n", "720.m3u8\n", 'URI="360-iframe-index.m3u8"')
      expect(master_text).not_to include('1080')

      preview = media_file.previews.find_by(conversion_profile: 'hls')
      expect(preview.media_type).to eq 'video'
      expect([preview.width, preview.height]).to eq [1280, 720]
    end
  end

  context 'with playlist URLs on signed storage' do
    let(:query) { 'Expires=1&Signature=abc' }
    let(:outputs) do
      [
        output('hls_360', "https://zc.example/o/2/abc.profile_hls_360.m3u8?#{query}"),
        output('hls', "https://zc.example/o/2/abc.profile_hls.m3u8?#{query}")
      ]
    end

    before do
      stub_request(:get, "https://zc.example/o/2/abc.profile_hls_360.m3u8?#{query}")
        .to_return(body: variant('segments.mp4'))
      stub_request(:get, "https://zc.example/o/2/segments.mp4?#{query}")
        .to_return(body: 'media-bytes')
      stub_request(:get, "https://zc.example/o/2/abc.profile_hls.m3u8?#{query}")
        .to_return(body: master.sub("360.m3u8\n", "abc.profile_hls_360.m3u8\n"))
    end

    it 'keeps the query string on referenced files and maps the master entry' do
      described_class.new(media_file, outputs).call

      expect(File.read(File.join(hls_dir, '360.mp4'))).to eq 'media-bytes'
      master_text = File.read(File.join(hls_dir, 'master.m3u8'))
      expect(master_text).to include("360.m3u8\n")
      expect(master_text).not_to include('720', 'iframe')
    end
  end

  context 'with the whole package as a zip on the master output' do
    let(:outputs) { [output('hls', 'https://zc.example/o/3/hls.zip')] }

    before do
      stub_request(:get, 'https://zc.example/o/3/hls.zip').to_return(
        body: zip_of(
          'hls/master.m3u8' => master.lines.first(4).join,
          'hls/360.m3u8' => variant('360.mp4'),
          'hls/360.mp4' => 'media-bytes'
        )
      )
    end

    it 'stores the package as it is' do
      described_class.new(media_file, outputs).call

      expect(Dir.children(hls_dir)).to match_array %w[master.m3u8 360.m3u8 360.mp4]
    end
  end

  it 'fails when the master playlist did not finish' do
    outputs = [output('hls_360', 'https://zc.example/x.zip'), output('hls', nil, state: 'failed')]

    expect { described_class.new(media_file, outputs).call }
      .to raise_error(ZencoderHlsImport::ImportError, 'master playlist failed')
  end

  it 'fails when a rung download fails' do
    stub_request(:get, 'https://zc.example/o/4/hls.m3u8').to_return(body: master)
    stub_request(:get, 'https://zc.example/o/4/360.zip').to_return(status: 403)
    outputs = [output('hls_360', 'https://zc.example/o/4/360.zip'), output('hls', 'https://zc.example/o/4/hls.m3u8')]

    expect { described_class.new(media_file, outputs).call }
      .to raise_error(ZencoderHlsImport::ImportError, %r{download 403 https://zc.example/o/4/360.zip})
    expect(media_file.previews.where(conversion_profile: 'hls')).to be_empty
  end
end
