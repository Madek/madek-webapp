require 'spec_helper'

describe Admin::VocabularyUserPermissionsController do
  let(:admin_user) { create :admin_user }
  let(:vocabulary) { create :vocabulary }

  describe '#index' do
    let(:first_user_permission) do
      create(:vocabulary_user_permission, vocabulary: vocabulary)
    end
    let(:second_user_permission) do
      create(:vocabulary_user_permission, vocabulary: vocabulary)
    end
    before { get :index, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'responds with HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @user_permissions correctly' do
      expect(assigns[:user_permissions]).to match_array(
        [first_user_permission, second_user_permission])
    end
  end

  describe '#new' do
    let(:new_user) { create(:user) }

    it 'assigns locals correctly' do
      get :new, { vocabulary_id: vocabulary.id }, user_id: admin_user.id

      expect(assigns[:vocabulary]).to eq vocabulary
      expect(assigns[:permission]).to be_an_instance_of(
        Permissions::VocabularyUserPermission)
    end

    it "assigns user_id value of permission's instance from params" do
      get(:new,
          {
            vocabulary_id: vocabulary.id,
            user_id: new_user.id
          },
          user_id: admin_user.id)

      expect(assigns[:permission].user_id).to eq new_user.id
    end

    it 'renders new template' do
      get(:new,
          { vocabulary_id: vocabulary.id },
          user_id: admin_user.id)

      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    it 'creates a permission correctly' do
      expect do
        post(:create,
             {
               vocabulary_id: vocabulary.id,
               vocabulary_user_permission: { user_id: create(:user).id }
             },
             user_id: admin_user.id)
      end.to change { Permissions::VocabularyUserPermission.count }.by(1)
    end

    it 'reset session vocabulary_id key' do
      session[:vocabulary_id] = 123

      post(:create,
           {
             vocabulary_id: vocabulary.id,
             vocabulary_user_permission: { user_id: create(:user).id }
           },
           user_id: admin_user.id)

      expect(session[:vocabulary_id]).to be_nil
    end

    it 'redirects to admin vocabulary user permissions path' do
      post(:create,
           {
             vocabulary_id: vocabulary.id,
             vocabulary_user_permission: { user_id: create(:user).id }
           },
           user_id: admin_user.id)

      expect(response).to redirect_to(
        admin_vocabulary_vocabulary_user_permissions_url(vocabulary))
    end

    it 'sets a correct flash message' do
      post(:create,
           {
             vocabulary_id: vocabulary.id,
             vocabulary_user_permission: { user_id: create(:user).id }
           },
           user_id: admin_user.id)

      expect(flash[:success]).to eq(
        'The Vocabulary User Permission has been created.')
    end
  end

  describe '#edit' do
    let(:permission) do
      create(:vocabulary_user_permission, vocabulary: vocabulary)
    end
    let(:new_user) { create(:user) }

    it 'assigns locals correctly' do
      get(:edit,
          {
            vocabulary_id: vocabulary.id,
            id: permission.id
          },
          user_id: admin_user.id)

      expect(assigns[:vocabulary]).to eq vocabulary
      expect(assigns[:permission]).to eq permission
    end

    it "assigns user_id value of permission's instance from params" do
      get(:edit,
          {
            vocabulary_id: vocabulary.id,
            id: permission.id,
            user_id: new_user.id
          },
          user_id: admin_user.id)

      expect(assigns[:permission].user_id).to eq new_user.id
    end
  end

  describe '#update' do
    let(:permission) do
      create(:vocabulary_user_permission,
             vocabulary: vocabulary,
             use: false,
             view: true)
    end
    before do
      patch :update,
            {
              vocabulary_user_permission: {
                user_id: admin_user.id,
                use: true,
                view: false
              },
              vocabulary_id: vocabulary.id,
              id: permission.id
            },
            user_id: admin_user.id
    end

    it 'updates the permission' do
      permission.reload

      expect(permission.user_id).to eq admin_user.id
      expect(permission.use).to be true
      expect(permission.view).to be false
    end

    it 'redirects to vocabulary user permissions path' do
      expect(response).to redirect_to(
        admin_vocabulary_vocabulary_user_permissions_url(vocabulary))
      expect(flash[:success]).to eq(
        'The Vocabulary User Permission has been updated.')
    end
  end

  describe '#destroy' do
    it 'deletes the permission' do
      permission = create(:vocabulary_user_permission, vocabulary: vocabulary)

      expect do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: permission.id },
          user_id: admin_user.id
        )
      end.to change { Permissions::VocabularyUserPermission.count }.by(-1)
    end
  end
end
