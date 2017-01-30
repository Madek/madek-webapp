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
          { id: zencoder_job.id }.merge(failed_notification)
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
          id: zencoder_job.id,
          job: { id: 12345 }
        )

        zencoder_job.reload

        expect(zencoder_job.state).to eq 'finished'
        expect(zencoder_job.progress).to eq 100.0
        expect(zencoder_job.notification).to eq job_details.to_s
      end
    end
  end
end
