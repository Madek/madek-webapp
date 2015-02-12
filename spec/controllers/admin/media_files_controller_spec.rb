require 'spec_helper'

describe Admin::MediaFilesController do
  let(:admin_user) { create :admin_user }
  let(:media_file) { create :media_file }

  describe '#show' do
    context 'when media file has not audio/video type' do
      before { get :show, { id: media_file.id }, user_id: admin_user.id }

      it 'responds with 200 HTTP status code' do
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'assigns @media_file correctly' do
        expect(assigns[:media_file]).to eq media_file
      end

      it 'does not assigns @zencoder_jobs' do
        expect(assigns[:zencoder_jobs]).to be_nil
      end
    end

    context 'when media file has audio/video type' do
      it 'assigns @zencoder_jobs when necessary' do
        allow_any_instance_of(MediaFile).to receive(:audio_video?).and_return(true)

        get :show, { id: media_file.id }, user_id: admin_user.id

        expect(assigns[:zencoder_jobs]).to be
      end
    end
  end
end
