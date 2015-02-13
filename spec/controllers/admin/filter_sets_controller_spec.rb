require 'spec_helper'

describe Admin::FilterSetsController do
  let(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with status code 200' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  describe '#show' do
    let!(:filter_set) { create :filter_set }

    it 'responds with status code 200' do
      get :show, { id: filter_set.id }, user_id: admin_user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: filter_set.id }, user_id: admin_user.id
      expect(response).to render_template(:show)
    end

    it 'loads the proper models into variables' do
      get :show, { id: filter_set.id }, user_id: admin_user.id
      expect(assigns[:filter_set]).to eq filter_set
      expect(assigns[:user]).to eq filter_set.responsible_user
    end
  end
end
