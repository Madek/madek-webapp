require 'spec_helper'

describe Admin::KeywordsController do
  let(:admin_user) { create :admin_user }
  let(:meta_key) { create :meta_key_keywords }
  let(:vocabulary) { meta_key.vocabulary }
  let(:keyword) { create :keyword, meta_key: meta_key }

  describe '#index' do
    before { get :index, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'responds with HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @keywords correctly' do
      expect(assigns[:keywords]).to eq [keyword]
    end

    describe 'filtering' do
      context 'by id' do
        it 'returns a proper keyword' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: keyword.id },
            user_id: admin_user.id
          )

          expect(assigns[:keywords]).to eq [keyword]
        end
      end

      context 'by term' do
        it 'returns a proper keyword' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: keyword.term[0, 2] },
            user_id: admin_user.id
          )

          expect(assigns[:keywords]).to eq [keyword]
        end
      end

      context 'by meta key' do
        it 'returns a proper keyword' do
          get(
            :index,
            {
              vocabulary_id: vocabulary.id,
              search_term: keyword.meta_key.id[0, 3]
            },
            user_id: admin_user.id
          )

          expect(assigns[:keywords]).to eq [keyword]
        end
      end
    end
  end

  describe '#edit' do
    it 'assigns @vocabulary and @keyword correctly' do
      get(
        :edit,
        { vocabulary_id: vocabulary.id, id: keyword.id },
        user_id: admin_user.id
      )

      expect(assigns[:vocabulary]).to eq vocabulary
      expect(assigns[:keyword]).to eq keyword
      expect(response).to render_template :edit
    end
  end

  describe '#update' do
    let(:params) do
      {
        vocabulary_id: vocabulary.id,
        id: keyword.id,
        keyword: {
          term: 'updated term'
        }
      }
    end

    it "updates the keyword's term" do
      put :update, params, user_id: admin_user.id

      expect(keyword.reload.term).to eq 'updated term'
      expect(flash[:success]).to eq flash_message(:update, :success)
    end

    it 'redirects to admin keyword path' do
      put :update, params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(
        admin_vocabulary_keywords_path(vocabulary)
      )
    end
  end

  describe '#new' do
    before { get :new, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'assigns @vocabulary correctly' do
      expect(assigns[:vocabulary]).to eq vocabulary
    end

    it 'assigns @keyword correctly' do
      expect(assigns[:keyword]).to be_an_instance_of(Keyword)
      expect(assigns[:keyword]).to be_new_record
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    let(:keyword_params) do
      {
        vocabulary_id: vocabulary.id,
        keyword: {
          term: 'new keyword',
          meta_key_id: meta_key.id
        }
      }
    end

    it 'creates a new keyword' do
      expect { post :create, keyword_params, user_id: admin_user.id }
        .to change { Keyword.count }.by(1)
    end

    it 'redirects to admin keywords path' do
      post :create, keyword_params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(
        admin_vocabulary_keywords_path(vocabulary)
      )
      expect(flash[:success]).not_to be_empty
    end

    it 'displays success message' do
      post :create, keyword_params, user_id: admin_user.id

      expect(flash[:success]).not_to be_empty
    end
  end

  describe '#destroy' do
    it 'destroys the keyword' do
      vocabulary and keyword

      expect do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: keyword.id },
          user_id: admin_user.id
        )
      end.to change { Keyword.count }.by(-1)
    end

    context 'when delete was successful' do
      before do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: keyword.id },
          user_id: admin_user.id
        )
      end

      it 'redirects to admin keywords path' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(
          admin_vocabulary_keywords_path(vocabulary)
        )
      end

      it 'displays success message' do
        expect(flash[:success]).to be_present
      end
    end

    context 'when keywords does not exist' do
      it 'renders error template' do
        delete(
          :destroy,
          {
            vocabulary_id: vocabulary.id,
            id: UUIDTools::UUID.random_create
          },
          user_id: admin_user.id
        )

        expect(response).to have_http_status(:not_found)
        expect(response).to render_template 'admin/errors/404'
      end
    end
  end

  def flash_message(action, type)
    I18n.t type, scope: "flash.actions.#{action}", resource_name: 'Keyword'
  end
end
