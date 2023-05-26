require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaFiles::MediaFile,  transact_check_or_seed_broken: true do
  before :example do
    @user = FactoryBot.create(:user)
  end

  it_can_be 'dumped' do
    media_entry = FactoryBot.create(:media_entry_with_video_media_file)

    let(:presenter) do
      described_class.new(
        media_entry,
        @user)
    end
  end

  describe '#conversion_progress' do
    let(:media_entry) do
      FactoryBot.create(:media_entry_with_video_media_file,
                         responsible_user: FactoryBot.create(:user))
    end

    context 'when zencoder job has pending state' do
      let(:zencoder_response) do
        double(:zencoder_response, body: { 'state' => 'pending' })
      end

      it 'returns 0.0' do
        FactoryBot.create(:zencoder_job, media_file: media_entry.media_file)
        p = described_class.new(media_entry, @user)

        allow(Zencoder::Job).to receive(:progress).and_return zencoder_response

        expect(p.conversion_progress).to eq 0.0
      end
    end

    context 'when zencoder job has processing state' do
      let(:zencoder_response) do
        double(:zencoder_response, body: { 'state' => 'processing',
                                           'progress' => 10.01 })
      end

      it 'returns 10.0' do
        FactoryBot.create(:zencoder_job, media_file: media_entry.media_file)
        p = described_class.new(media_entry, @user)

        allow(Zencoder::Job).to receive(:progress).and_return zencoder_response

        expect(p.conversion_progress).to eq 10.0
      end
    end
  end
end
