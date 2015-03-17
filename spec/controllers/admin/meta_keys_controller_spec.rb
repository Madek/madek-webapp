require 'spec_helper'

describe Admin::MetaKeysController do
  let(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with 200 HTTP status code' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    context 'filtering by meta datum object type' do
      it 'assigns @meta_keys properly filtered' do
        meta_key_title = create :meta_key_title
        create :meta_key_people
        type_param = meta_key_title.meta_datum_object_type

        get(
          :index,
          { type: type_param },
          user_id: admin_user.id
        )

        assigns[:meta_keys].each do |meta_key|
          expect(meta_key.meta_datum_object_type).to eq type_param
        end
      end
    end

    context 'filtering by ID' do
      it 'returns correct collection of meta keys' do
        meta_key_1 = create :meta_key_title, id: 'bar:foo'
        meta_key_2 = create :meta_key_title, id: 'foo:bar'

        get :index, { search_term: 'foo' }, user_id: admin_user.id

        expect(assigns[:meta_keys]).to match_array([meta_key_1, meta_key_2])
      end
    end

    context 'filtering by label' do
      it 'returns correct collection of meta keys' do
        meta_key_1 = create :meta_key_title, label: 'foo:bar'
        meta_key_2 = create :meta_key_vocables, label: 'bar:foo'

        get :index, { search_term: 'bar' }, user_id: admin_user.id

        expect(assigns[:meta_keys]).to match_array([meta_key_1, meta_key_2])
      end
    end

    context 'filtering by vocabulary' do
      it 'returns correct collection of meta keys' do
        vocabulary = create :vocabulary
        meta_key_1 = create :meta_key_vocables, vocabulary: vocabulary
        meta_key_2 = create(:meta_key_vocables,
                            id: 'test:vocables_2',
                            vocabulary: vocabulary)

        get(
          :index,
          { vocabulary_id: vocabulary.id },
          user_id: admin_user.id
        )

        expect(assigns[:meta_keys]).to match_array([meta_key_1, meta_key_2])
      end
    end
  end

  describe '#edit' do
    let(:meta_key) { create :meta_key_title }
    before { get :edit, { id: meta_key.id }, user_id: admin_user.id }

    it 'responds with 200 HTTP status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @meta_key correctly' do
      expect(assigns[:meta_key]).to eq meta_key
    end
  end

  describe '#update' do
    let(:meta_key) { create :meta_key_title }
    let(:meta_key_params) do
      {
        label: 'NEW_LABEL',
        description: 'NEW_DESCRIPTION',
        hint: 'NEW_HINT',
        meta_datum_object_type: 'MetaDatum::TestValue'
      }
    end
    before do
      patch(
        :update,
        { id: meta_key.id, meta_key: meta_key_params },
        user_id: admin_user.id
      )
    end

    it 'redirects to edit admin meta key path' do
      expect(response).to redirect_to edit_admin_meta_key_path(meta_key)
    end

    it 'displays success message' do
      expect(flash[:success]).to eq 'The meta key has been updated.'
    end

    it 'updates the meta key' do
      meta_key.reload
      expect(meta_key.label).to eq 'NEW_LABEL'
      expect(meta_key.description).to eq 'NEW_DESCRIPTION'
      expect(meta_key.hint).to eq 'NEW_HINT'
      expect(meta_key.meta_datum_object_type).to eq 'MetaDatum::TestValue'
    end
  end

  describe '#show' do
    let(:meta_key) { create :meta_key_title }
    before { get :show, { id: meta_key.id }, user_id: admin_user.id }

    it 'responds with the success' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders show template' do
      expect(response).to render_template :show
    end

    it 'assigns @meta_key correctly' do
      expect(assigns[:meta_key]).to eq meta_key
    end
  end

  describe '#destroy' do
    let!(:meta_key) { create :meta_key_title }

    it 'redirects to admin meta keys path' do
      delete :destroy, { id: meta_key.id }, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_meta_keys_path)
    end

    it 'deletes the meta key' do
      expect do
        delete :destroy, { id: meta_key.id }, user_id: admin_user.id
      end.to change { MetaKey.count }.by(-1)
    end

    it 'sets correct flash message' do
      delete :destroy, { id: meta_key.id }, user_id: admin_user.id

      expect(flash[:success]).to eq 'The meta key has been deleted.'
    end

    context 'when a meta key does not exist' do
      it 'renders error page' do
        delete :destroy, { id: 123 }, user_id: admin_user.id

        expect(response).to have_http_status(404)
        expect(response).to render_template 'errors/404'
      end
    end
  end

  describe '#new' do
    before { get :new, {}, user_id: admin_user.id }

    it 'assigns @meta_key correctly' do
      expect(assigns[:meta_key]).to be_instance_of(MetaKey)
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    let(:vocabulary) { create :vocabulary }
    let(:meta_key_params) do
      {
        id: 'test:id',
        label: 'NEW_LABEL',
        description: 'NEW_DESCRIPTION',
        hint: 'NEW_HINT',
        is_extensible_list: true,
        vocabulary_id: vocabulary.id
      }
    end

    it 'creates a new meta key' do
      expect do
        post :create, { meta_key: meta_key_params }, user_id: admin_user.id
      end.to change { MetaKey.count }.by(1)
    end

    it 'redirects to edit admin meta key path' do
      post :create, { meta_key: meta_key_params }, user_id: admin_user.id

      meta_key = MetaKey.find_by(meta_key_params)

      expect(response).to redirect_to edit_admin_meta_key_path(meta_key)
    end

    it 'sets a success message correctly' do
      post :create, { meta_key: meta_key_params }, user_id: admin_user.id

      expect(flash[:success]).to eq 'The meta key has been created.'
    end
  end
end
