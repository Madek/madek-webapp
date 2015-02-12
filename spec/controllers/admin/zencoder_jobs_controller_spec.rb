require 'spec_helper'

describe Admin::ZencoderJobsController do
  let(:admin_user) { create :admin_user }
  let(:zencoder_job) { create :zencoder_job }

  describe '#show' do
    before { get :show, { id: zencoder_job.id }, user_id: admin_user.id }

    it 'responds with 200 HTTP status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @zencoder_job correctly' do
      expect(assigns[:zencoder_job]).to eq zencoder_job
    end
  end
end
