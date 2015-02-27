require 'spec_helper'

describe Admin::ApiClientsController do
  let(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with HTTP 200 status code' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'loads the first page of api_clients into api_clients' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(assigns(:api_clients)).to eq ApiClient.first(16)
    end
  end

  describe '#show' do
    let(:api_client) { create :api_client }

    it 'responds with HTTP 200 status code' do
      get :show, { id: api_client.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: api_client.id }, user_id: admin_user.id

      expect(response).to render_template(:show)
    end

    it 'loads the proper api_client into api_client' do
      get :show, { id: api_client.id }, user_id: admin_user.id

      expect(assigns[:api_client]).to eq api_client
    end
  end

  describe '#edit' do
    let(:api_client) { create :api_client }

    it 'responds with HTTP 200 status code' do
      get :edit, { id: api_client.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'render the edit template and assigns the api_client to api_client' do
      get :edit, { id: api_client.id }, user_id: admin_user.id

      expect(response).to render_template(:edit)
      expect(assigns[:api_client]).to eq api_client
    end
  end

  describe '#update' do
    let(:api_client) { create :api_client }

    it 'redirects to admin api_client show page' do
      patch(
        :update,
        { id: api_client.id, api_client: { description: 'test description' } },
        user_id: admin_user.id
      )

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_api_client_path(api_client))
    end

    it 'updates the api_client' do
      patch(
        :update,
        { id: api_client.id, api_client: { description: 'test description' } },
        user_id: admin_user.id
      )

      expect(flash[:success]).to eq flash_message(:update, :success)
      expect(api_client.reload.description).to eq 'test description'
    end
  end

  describe '#create' do
    let(:user) { create :user }
    let(:api_client_params) do
      {
        login: Faker::Lorem.words(2).join('_').slice(0, 20),
        description: Faker::Lorem.words(10).join(' '),
        user_id: user.id
      }
    end

    it 'redirects to admin api_clients path after successful create' do
      post :create, { api_client: api_client_params }, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_api_clients_path)
      expect(flash[:success]).to eq flash_message(:create, :success)
    end

    it 'creates an api_client' do
      expect do
        post :create, { api_client: api_client_params }, user_id: admin_user.id
      end.to change { ApiClient.count }.by(1)
    end
  end

  describe '#destroy' do
    let!(:api_client) { create :api_client }

    it 'redirects to admin api_clients path after succesful destroy' do
      delete :destroy, { id: api_client.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_api_clients_path)
      expect(flash[:success]).to eq flash_message(:destroy, :success)
    end

    it 'destroys the api_client' do
      expect do
        delete :destroy, { id: api_client.id }, user_id: admin_user.id
      end.to change { ApiClient.count }.by(-1)
    end
  end

  def flash_message(action, type)
    I18n.t type, scope: "flash.actions.#{action}", resource_name: 'Api client'
  end
end
