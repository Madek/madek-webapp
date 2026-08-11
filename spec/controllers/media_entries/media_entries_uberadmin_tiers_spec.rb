require 'spec_helper'

describe MediaEntriesController do
  let(:restricted_entry) do
    create(:media_entry,
           responsible_user: create(:user),
           get_metadata_and_previews: false,
           is_published: true)
  end

  context 'view-only tier (uberadmin_view)' do
    let(:admin) { admin_user_with_only('uberadmin_view') }
    let(:session_hash) { { user_id: admin.id, uberadmin_mode: true } }

    it 'allows show' do
      get :show, params: { id: restricted_entry.id }, session: session_hash

      expect(response).to have_http_status(200)
    end

    it 'allows browse' do
      get :browse, params: { id: restricted_entry.id }, session: session_hash

      expect(response).to have_http_status(200)
    end

    it 'denies destroy' do
      expect do
        delete :destroy, params: { id: restricted_entry.id }, session: session_hash
      end.to raise_error(Errors::ForbiddenError)
    end
  end

  context 'edit tier (uberadmin_edit)' do
    let(:admin) { admin_user_with_only('uberadmin_edit') }
    let(:session_hash) { { user_id: admin.id, uberadmin_mode: true } }

    it 'allows show' do
      get :show, params: { id: restricted_entry.id }, session: session_hash

      expect(response).to have_http_status(200)
    end

    it 'allows destroy' do
      delete :destroy, params: { id: restricted_entry.id }, session: session_hash

      expect(restricted_entry.reload.deleted_at).to be_present
    end
  end
end
