require 'spec_helper'

describe ZencoderJobsController, webmock: true do
  let(:media_file) { create :media_file_for_movie }
  let(:zencoder_job) do
    create(:zencoder_job,
           media_file: media_file,
           zencoder_id: 12345)
  end
  let(:failed_notification) do
    {
      job: {
        'created_at' => '2011-09-27T04:20:10Z',
        'pass_through' => nil,
        'updated_at' => '2011-09-27T04:21:18Z',
        'submitted_at' => '2011-09-27T04:20:10Z',
        'id' => 12345,
        'state' => 'failed'
      }
    }
  end
  let(:job_details) do
    {
      'job' => {
        'created_at' => '2010-01-01T00:00:00Z',
        'finished_at' => '2010-01-01T00:00:00Z',
        'updated_at' => '2010-01-01T00:00:00Z',
        'submitted_at' => '2010-01-01T00:00:00Z',
        'pass_through' => nil,
        'id' => 12345,
        'input_media_file' => {
          'format' => 'mpeg4',
          'created_at' => '2010-01-01T00:00:00Z',
          'frame_rate' => 29,
          'finished_at' => '2010-01-01T00:00:00Z',
          'updated_at' => '2010-01-01T00:00:00Z',
          'duration_in_ms' => 24883,
          'audio_sample_rate' => 48000,
          'url' => 's3://bucket/test.mp4',
          'id' => 1,
          'error_message' => nil,
          'error_class' => nil,
          'audio_bitrate_in_kbps' => 95,
          'audio_codec' => 'aac',
          'height' => 352,
          'file_size_bytes' => 1_862_748,
          'video_codec' => 'h264',
          'test' => false,
          'total_bitrate_in_kbps' => 593,
          'channels' => '2',
          'width' => 624,
          'video_bitrate_in_kbps' => 498,
          'state' => 'finished',
          'md5_checksum' => '7f106918e02a69466afa0ee014174143'
        },
        'test' => false,
        'output_media_files' => [{
          'format' => 'mpeg4',
          'created_at' => '2010-01-01T00:00:00Z',
          'frame_rate' => 29,
          'finished_at' => '2010-01-01T00:00:00Z',
          'updated_at' => '2010-01-01T00:00:00Z',
          'duration_in_ms' => 24883,
          'audio_sample_rate' => 44100,
          'url' => 'http://s3.amazonaws.com/bucket/video.mp4',
          'id' => 1,
          'error_message' => nil,
          'error_class' => nil,
          'audio_bitrate_in_kbps' => 92,
          'audio_codec' => 'aac',
          'height' => 352,
          'file_size_bytes' => 1_386_663,
          'video_codec' => 'h264',
          'test' => false,
          'total_bitrate_in_kbps' => 443,
          'channels' => '2',
          'width' => 624,
          'video_bitrate_in_kbps' => 351,
          'state' => 'finished',
          'label' => 'Web',
          'md5_checksum' => '7f106918e02a69466afa0ee014172496'
        }],
        'thumbnails' => [{
          'created_at' => '2010-01-01T00:00:00Z',
          'updated_at' => '2010-01-01T00:00:00Z',
          'url' => 'http://s3.amazonaws.com/bucket/video/frame_0000.png',
          'id' => 1,
          'format' => 'jpeg'
        }],
        'state' => 'finished'
      }
    }
  end

  describe '#notification' do
    context 'when job failed' do
      it 'persists state of the zencoder job' do
        allow(Zencoder::Job).to receive(:details).and_raise('An error occurred!')

        post(
          :notification,
          params: { id: zencoder_job.id }.merge(failed_notification)
        )

        zencoder_job.reload

        expect(zencoder_job.state).to eq 'failed'
        expect(zencoder_job.error).to eq 'An error occurred!'
      end
    end

    context 'when job finished successfully' do
      before do
        allow(Zencoder).to receive(:api_key).and_return('abcd1235')
        stub_request(:get, 'https://app.zencoder.com/api/v2/jobs/12345')
          .with(headers: { 'Zencoder-Api-Key' => 'abcd1235' })
          .to_return(body: job_details.to_json)
        stub_request(:get, 'http://s3.amazonaws.com/bucket/video.mp4')
        stub_request(:get, 'http://s3.amazonaws.com/bucket/video/frame_0000.png')
        allow(FileConversion).to receive(:convert)
      end

      it 'persists notification data' do
        post(
          :notification,
          params: {
            id: zencoder_job.id,
            job: { id: 12345 } }
        )

        zencoder_job.reload

        expect(zencoder_job.state).to eq 'finished'
        expect(zencoder_job.progress).to eq 100.0
        expect(zencoder_job.notification).to eq job_details.to_s
      end
    end

    context 'when the job includes an HLS package' do
      let(:hls_zip) do
        dir = Dir.mktmpdir
        File.write(File.join(dir, '360.mp4'), 'media-bytes')
        File.write(File.join(dir, '360.m3u8'), <<~M3U8)
          #EXTM3U
          #EXT-X-MAP:URI="https://zencoder.example/360.mp4"
          #EXTINF:6,
          https://zencoder.example/360.mp4
          #EXT-X-ENDLIST
        M3U8
        File.write(File.join(dir, 'master.m3u8'), <<~M3U8)
          #EXTM3U
          #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
          360.m3u8
        M3U8
        buffer = Zip::OutputStream.write_buffer do |out|
          %w[master.m3u8 360.m3u8 360.mp4].each do |name|
            out.put_next_entry(name)
            out.write(File.binread(File.join(dir, name)))
          end
        end
        buffer.rewind
        buffer.read
      end

      before do
        allow(Zencoder).to receive(:api_key).and_return('abcd1235')
        details = job_details.deep_dup
        details['job']['thumbnails'] = []
        details['job']['output_media_files'] = [
          job_details['job']['output_media_files'].first,
          {
            'label' => 'hls',
            'state' => 'finished',
            'url' => 'http://s3.amazonaws.com/bucket/hls.zip',
            'format' => 'zip'
          }
        ]
        stub_request(:get, 'https://app.zencoder.com/api/v2/jobs/12345')
          .with(headers: { 'Zencoder-Api-Key' => 'abcd1235' })
          .to_return(body: details.to_json)
        stub_request(:get, 'http://s3.amazonaws.com/bucket/video.mp4')
        stub_request(:get, 'http://s3.amazonaws.com/bucket/hls.zip')
          .to_return(body: hls_zip, headers: { 'Content-Type' => 'application/zip' })
      end

      it 'stores one hls preview and leaves the ladder off the preview table' do
        post :notification, params: { id: zencoder_job.id, job: { id: 12345 } }

        expect(zencoder_job.reload.state).to eq 'finished'
        hls = media_file.previews.where(conversion_profile: 'hls')
        expect(hls.count).to eq 1
        expect(hls.first.media_type).to eq 'video'
        expect(File.file?(File.join(media_file.thumbnail_store_location, 'hls', 'master.m3u8'))).to be true
        expect(File.read(File.join(media_file.thumbnail_store_location, 'hls', '360.m3u8'))).to include('URI="360.mp4"')
        expect(media_file.previews.where("filename LIKE '%m4f'")).to be_empty
      end
    end
  end
end
