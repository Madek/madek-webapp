require 'spec_helper'

describe Admin::UsersController do
  let!(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with HTTP 200 status code' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'loads the first page of users into @users' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(assigns(:users)).to eq User.first(16)
    end

    describe 'filtering users' do
      context 'by login' do
        it "returns users containing 'xxx' in login" do
          user_1 = create :user, login: 'adamxxx'
          user_2 = create :user, login: 'adamxxx'
          user_3 = create :user, login: 'adxxxam'

          get :index, { search_term: 'xxx' }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to eq [user_1, user_2, user_3]
        end
      end

      context 'by email' do
        it "returns users containing 'xxx' in email" do
          user_1 = create :user, email: 'adamxxx@madek.zhdk.ch'
          user_2 = create :user, email: 'adam@madekxxx.zhdk.ch'
          user_3 = create :user, email: 'adxxxam@madek.zhdk.ch'

          get :index, { search_term: 'xxx' }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to match_array [user_1, user_2, user_3]
        end
      end

      context 'by admin role' do
        it 'returns only admin users' do
          get :index, { admins_only: 1 }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to match_array User.admin_users
        end
      end
    end

    describe 'sorting users' do
      context 'by login (default)' do
        it 'returns users sorted by login in ascending order' do
          get :index, nil, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns[:users]).to eq User.page(1).per(16)
        end
      end

      context 'by email address' do
        it 'returns users sorted by email in ascending order' do
          get :index, { sort_by: :email }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns[:users].pluck(:email)).to eq(
            assigns[:users].pluck(:email).sort)
        end
      end

      context 'by person first name and last name' do
        it 'returns users with a correct order' do
          get :index, { sort_by: :first_name_last_name }, user_id: admin_user.id

          expect(response).to be_success
          expect(full_names(assigns[:users])).to eq(
            full_names(assigns[:users]).sort)
        end
      end

      def full_names(users)
        users.to_a.map(&:person).map(&:to_s)
      end
    end
  end

  describe '#show' do
    let(:user) { create :user }

    it 'responds with HTTP 200 status code' do
      get :show, { id: user.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: user.id }, user_id: admin_user.id

      expect(response).to render_template(:show)
    end

    it 'loads the proper user into @user' do
      get :show, { id: user.id }, user_id: admin_user.id

      expect(assigns[:user]).to eq user
    end
  end

  describe '#switch_to' do
    let(:user) { create :user }

    it 'redirects to the root path' do
      post :switch_to, { id: user.id }, user_id: admin_user.id

      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(302)
    end

  end

  describe '#reset_usage_terms' do
    let(:user) { create :user }

    it 'redirects to admin users path' do
      patch :reset_usage_terms, { id: user.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_users_path)
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq 'The usage terms have been reset.'
    end

    it 'resets usage terms for the user' do
      patch :reset_usage_terms, { id: user.id }, user_id: admin_user.id

      expect(user.reload.usage_terms_accepted_at).to be_nil
    end
  end

  describe '#grant_admin_role' do
    let(:user) { create :user }

    it 'redirects to the given redirect path' do
      patch(
        :grant_admin_role,
        { id: user.id, redirect_path: admin_user_path(user) },
        user_id: admin_user.id
      )

      expect(response).to redirect_to(admin_user_path(user))
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq(
        'The admin role has been granted to the user.')
    end

    it 'grants the admin role to the user' do
      patch(
        :grant_admin_role,
        { id: user.id, redirect_path: admin_users_path },
        user_id: admin_user.id
      )

      expect(user.reload).to be_admin
    end

    context 'when some error occured during action' do
      it 'renders error template' do
        allow(Admin).to receive(:create!).and_raise(ActiveRecord::RecordNotFound)

        patch(
          :grant_admin_role,
          { id: user.id, redirect_path: admin_user_path(user) },
          user_id: admin_user.id
        )

        expect(response).to have_http_status(:not_found)
        expect(response).to render_template 'admin/errors/404'
      end
    end
  end

  describe '#remove_admin_role' do
    let(:user) { create :admin_user }

    it 'redirects to the given redirect path' do
      delete(
        :remove_admin_role,
        { id: user.id, redirect_path: admin_users_path },
        user_id: admin_user.id
      )

      expect(response).to redirect_to(admin_users_path)
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq(
        'The admin role has been removed from the user.')
    end

    it 'removes the admin role from the user' do
      delete(
        :remove_admin_role,
        { id: user.id, redirect_path: admin_user_path(user) },
        user_id: admin_user.id
      )

      expect(user.reload).not_to be_admin
    end
  end

  describe '#edit' do
    let(:user) { create :user }

    it 'responds with HTTP 200 status code' do
      get :edit, { id: user.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'render the edit template and assigns the user to @user' do
      get :edit, { id: user.id }, user_id: admin_user.id

      expect(response).to render_template(:edit)
      expect(assigns[:user]).to eq user
    end
  end

  describe '#update' do
    let(:user) { create :user }

    it 'redirects to admin user show page' do
      patch(
        :update,
        { id: user.id, user: { login: 'george' } },
        user_id: admin_user.id
      )

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_user_path(user))
    end

    it 'updates the user' do
      patch(
        :update,
        { id: user.id, user: { login: 'george' } },
        user_id: admin_user.id
      )

      expect(flash[:success]).to eq flash_message(:update, :success)
      expect(user.reload.login).to eq 'george'
    end

    it 'renders error template when something went wrong' do
      patch :update, { id: UUIDTools::UUID.random_create }, user_id: admin_user.id

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template 'admin/errors/404'
    end
  end

  describe '#create' do
    context 'without person' do
      it 'redirects to admin users path after successfuly created user' do
        post :create, { user: user_params }, user_id: admin_user.id

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:success]).to eq flash_message(:create, :success)
      end

      it 'creates an user' do
        expect do
          post :create, { user: user_params }, user_id: admin_user.id
        end.to change { User.count }.by(1)
      end

      context 'when validation failed' do
        it 'renders error template' do
          post :create, { user: { email: '' } }, user_id: admin_user.id

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template 'admin/errors/422'
        end
      end

      def user_params
        {
          login: Faker::Internet.user_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          person_id: create(:person).id
        }
      end
    end

    context 'with person' do
      it 'redirects to admin users path after successfuly created user' do
        post :create, { user: user_params }, user_id: admin_user.id

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:success]).to eq flash_message(:create, :success)
      end

      it 'creates an user' do
        expect do
          post :create, { user: user_params }, user_id: admin_user.id
        end.to change { User.count }.by(1)
      end

      context 'when validation failed' do
        it 'renders error template' do
          attributes = {
            login: 'example-login',
            email: 'nickname@example.com',
            person_attributes: {}
          }
          post :create, { user: attributes }, user_id: admin_user.id

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template 'admin/errors/422'
        end
      end

      def user_params
        {
          login: Faker::Internet.user_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          person_attributes: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name
          }
        }
      end
    end
  end

  describe '#destroy' do
    let!(:user) { create :user }

    it 'redirects to admin users path after succesful destroy' do
      delete :destroy, { id: user.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:success]).to eq flash_message(:destroy, :success)
    end

    it 'destroys the user' do
      expect do
        delete :destroy, { id: user.id }, user_id: admin_user.id
      end.to change { User.count }.by(-1)
    end
  end

  def flash_message(action, type)
    I18n.t type, scope: "flash.actions.#{action}", resource_name: 'User'
  end
end
