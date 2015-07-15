require 'spec_helper'

describe Admin::IoInterfacesController do

  before :context do
    @admin_user = create(:admin_user)
  end

  context '#index' do
    it 'responds with 200 HTTP status code' do
      get :index, nil, user_id: @admin_user.id

      expect(response).to be_success
      expect(response).to render_template :index
      expect(response).to have_http_status(200)
    end

    it '#update is prohibited' do
      @io_interface = create(:io_interface)
      expect do
        put(:update,
            { id: @io_interface.id,
              description: Faker::Lorem.sentence },
            user_id: @admin_user.id)
      end
        .to raise_error ActionController::UrlGenerationError
    end

    it '#show' do
      @io_interface = create(:io_interface)
      get :show, { id: @io_interface.id }, user_id: @admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template :show
      expect(assigns[:io_interface]).to eq @io_interface
    end

    it '#destroy' do
      @io_interface = create(:io_interface)
      delete :destroy, { id: @io_interface.id }, user_id: @admin_user.id
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_io_interfaces_path)
    end

    it '#create' do
      io_interface_params = {
        id: Faker::Lorem.characters(10),
        description: Faker::Lorem.sentence
      }

      expect do
        post(:create,
             { io_interface: io_interface_params },
             user_id: @admin_user.id)
      end.to change { IoInterface.count }.by(1)
    end
  end
end
