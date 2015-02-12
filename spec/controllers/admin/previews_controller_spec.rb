require 'spec_helper'

describe Admin::PreviewsController do
  let(:admin_user) { create :admin_user }
  let(:preview) { create :preview, media_file_id: create(:media_file) }

  describe '#show' do
    before { get :show, { id: preview.id }, user_id: admin_user.id }

    it 'responds with HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @preview correctly' do
      expect(assigns(:preview)).to eq preview
    end
  end

  describe '#destroy' do
    before { @preview = create :preview, media_file_id: create(:media_file) }

    it 'destroys preview' do
      expect { delete :destroy, { id: @preview.id }, user_id: admin_user.id }
        .to change { Preview.count }.by(-1)
    end

    context 'when preview is destroyed successfully' do
      it 'redirects to admin media file path with success message' do
        delete :destroy, { id: @preview.id }, user_id: admin_user.id

        expect(response).to redirect_to(admin_media_file_path(@preview.media_file))
        expect(flash[:success]).to eq 'The preview has been deleted.'
      end
    end

    context 'when any error occured' do
      it 'redirects to admin media file path with error message' do
        allow_any_instance_of(Preview).to receive(:destroy!).and_raise('error')

        delete :destroy, { id: @preview.id }, user_id: admin_user.id

        expect(response).to redirect_to(admin_media_file_path(@preview.media_file))
        expect(flash[:error]).to eq 'error'
      end
    end
  end
end
