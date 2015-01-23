require 'spec_helper'

describe Admin::UsersController do
  before do
    @admin_user = create :admin_user
  end

  describe '#index' do
    it 'responds with HTTP 200 status code' do
      get :index, nil, user_id: @admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'loads the first page of users into @users' do
      get :index, nil, user_id: @admin_user.id

      expect(response).to be_success
      expect(assigns(:users)).to eq User.first(16)
    end

    describe 'filtering users' do
      context 'by login' do
        it "returns users containing 'xxx' in login" do
          user_1 = create :user, login: 'adamxxx'
          user_2 = create :user, login: 'adamxxx'
          user_3 = create :user, login: 'adxxxam'

          get :index, { search_term: 'xxx' }, user_id: @admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to eq [user_1, user_2, user_3]
        end
      end

      context 'by email' do
        it "returns users containing 'xxx' in email" do
          user_1 = create :user, email: 'adamxxx@madek.zhdk.ch'
          user_2 = create :user, email: 'adam@madekxxx.zhdk.ch'
          user_3 = create :user, email: 'adxxxam@madek.zhdk.ch'

          get :index, { search_term: 'xxx' }, user_id: @admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to match_array [user_1, user_2, user_3]
        end
      end

      context 'by admin role' do
        it 'returns only admin users' do
          get :index, { admins_only: 1 }, user_id: @admin_user.id

          expect(response).to be_success
          expect(assigns(:users)).to match_array User.admin_users
        end
      end
    end

    describe 'sorting users' do
      context 'by login (default)' do
        it 'returns users sorted by login in ascending order' do
          get :index, nil, user_id: @admin_user.id

          expect(response).to be_success
          expect(assigns[:users]).to eq User.page(1).per(16)
        end
      end

      context 'by email address' do
        it 'returns users sorted by email in ascending order' do
          get :index, { sort_by: :email }, user_id: @admin_user.id

          expect(response).to be_success
          expect(assigns[:users].pluck(:email)).to eq(
            assigns[:users].pluck(:email).sort)
        end
      end

      context 'by person first name and last name' do
        it 'returns users with a correct order' do
          get :index, { sort_by: :first_name_last_name }, user_id: @admin_user.id

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
    before do
      @user = create :user
    end

    it 'responds with HTTP 200 status code' do
      get :show, { id: @user.id }, user_id: @admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: @user.id }, user_id: @admin_user.id

      expect(response).to render_template(:show)
    end

    it 'loads the proper user into @user' do
      get :show, { id: @user.id }, user_id: @admin_user.id

      expect(assigns[:user]).to eq @user
    end
  end

  describe '#switch_to' do
    before do
      @user = create :user
    end

    it 'redirects to the root path' do
      post :switch_to, { id: @user.id }, user_id: @admin_user.id

      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(302)
    end

    it 'sets the session user properly' do
      post :switch_to, { id: @user.id }, user_id: @admin_user.id

      expect(session[:user_id]).to eq @user.id
    end
  end

  describe '#reset_usage_terms' do
    before do
      @user = create :user
    end

    it 'redirects to admin users path' do
      patch :reset_usage_terms, { id: @user.id }, user_id: @admin_user.id

      expect(response).to redirect_to(admin_users_path)
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq 'The usage terms have been reset.'
    end

    it 'resets usage terms for the user' do
      patch :reset_usage_terms, { id: @user.id }, user_id: @admin_user.id

      expect(@user.reload.usage_terms_accepted_at).to be_nil
    end
  end

  describe '#grant_admin_role' do
    before do
      @user = create :user
      @request.headers['HTTP_REFERER'] = 'http://example.com/admin/users'
    end

    it 'redirects to recently visited page' do
      patch :grant_admin_role, { id: @user.id }, user_id: @admin_user.id

      expect(response).to redirect_to('http://example.com/admin/users')
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq 'The admin role has been granted to the user.'
    end

    it 'grants the admin role to the user' do
      patch :grant_admin_role, { id: @user.id }, user_id: @admin_user.id

      expect(@user.reload).to be_admin
    end
  end

  describe '#remove_admin_role' do
    before do
      @user = create :admin_user
      @request.headers['HTTP_REFERER'] = 'http://example.com/admin/users'
    end

    it 'redirects to HTTP referer' do
      delete :remove_admin_role, { id: @user.id }, user_id: @admin_user.id

      expect(response).to redirect_to('http://example.com/admin/users')
      expect(response).to have_http_status(302)
      expect(flash[:success]).to eq(
        'The admin role has been removed from the user.')
    end

    it 'removes the admin role from the user' do
      delete :remove_admin_role, { id: @user.id }, user_id: @admin_user.id

      expect(@user.reload).not_to be_admin
    end
  end

  describe '#edit' do
    before do
      @user = create :user
    end

    it 'responds with HTTP 200 status code' do
      get :edit, { id: @user.id }, user_id: @admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'render the edit template and assigns the user to @user' do
      get :edit, { id: @user.id }, user_id: @admin_user.id

      expect(response).to render_template(:edit)
      expect(assigns[:user]).to eq @user
    end
  end

  describe '#update' do
    before do
      @user = create :user
    end

    it 'redirects to admin user show page' do
      patch(
        :update,
        { id: @user.id, user: { login: 'george' } },
        user_id: @admin_user.id
      )

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_user_path(@user))
    end

    it 'updates the user' do
      patch(
        :update,
        { id: @user.id, user: { login: 'george' } },
        user_id: @admin_user.id
      )

      expect(flash[:success]).to eq 'The user has been updated.'
      expect(@user.reload.login).to eq 'george'
    end

    it 'displays error message when something went wrong' do
      patch :update, { id: @user.id }, user_id: @admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(edit_admin_user_path(@user))
      expect(flash[:error]).not_to be_nil
    end
  end

  describe '#create' do
    context 'without person' do
      it 'redirects to admin users path after successfuly created user' do
        post :create, { user: user_params }, user_id: @admin_user.id

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:success]).to eq(
          'The user for existing person has been created.')
      end

      it 'creates an user' do
        expect do
          post :create, { user: user_params }, user_id: @admin_user.id
        end.to change { User.count }.by(1)
      end

      context 'when validation failed' do
        it "renders 'new' template" do
          post :create, nil, user_id: @admin_user.id

          expect(response).to be_success
          expect(response).to have_http_status(200)
          expect(response).to render_template(:new)
          expect(flash[:error]).to be_present
        end

        it 'assigns @user with previously given values' do
          attributes = { login: 'example-login', email: 'nickname@example.com' }
          post :create, { user: attributes }, user_id: @admin_user.id

          expect(assigns[:user].login).to eq 'example-login'
          expect(assigns[:user].email).to eq 'nickname@example.com'
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
        post :create, { user: user_params }, user_id: @admin_user.id

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:success]).to eq 'The user with person has been created.'
      end

      it 'creates an user' do
        expect do
          post :create, { user: user_params }, user_id: @admin_user.id
        end.to change { User.count }.by(1)
      end

      context 'when validation failed' do
        it 'assigns @user with previously given values' do
          attributes = {
            login: 'example-login',
            email: 'nickname@example.com',
            person_attributes: {}
          }
          post :create, { user: attributes }, user_id: @admin_user.id

          expect(assigns[:user].login).to eq 'example-login'
          expect(assigns[:user].email).to eq 'nickname@example.com'
          expect(response).to render_template(:new_with_person)
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
      delete :destroy, { id: user.id }, user_id: @admin_user.id

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:success]).to eq 'The user has been deleted.'
    end

    it 'destroys the user' do
      expect do
        delete :destroy, { id: user.id }, user_id: @admin_user.id
      end.to change { User.count }.by(-1)
    end
  end
end
