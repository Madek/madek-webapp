require 'spec_helper'

describe Admin::KeywordTermsController do
  let(:admin_user) { create :admin_user }
  let(:meta_key) { create :meta_key_keywords }
  let(:vocabulary) { meta_key.vocabulary }
  let(:keyword_term) { create :keyword_term, meta_key: meta_key }

  describe '#index' do
    before { get :index, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'responds with HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @keyword_terms correctly' do
      expect(assigns[:keyword_terms]).to eq [keyword_term]
    end

    describe 'filtering' do
      context 'by id' do
        it 'returns a proper keyword_term' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: keyword_term.id },
            user_id: admin_user.id
          )

          expect(assigns[:keyword_terms]).to eq [keyword_term]
        end
      end

      context 'by term' do
        it 'returns a proper keyword_term' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: keyword_term.term[0, 2] },
            user_id: admin_user.id
          )

          expect(assigns[:keyword_terms]).to eq [keyword_term]
        end
      end

      context 'by meta key' do
        it 'returns a proper keyword_term' do
          get(
            :index,
            {
              vocabulary_id: vocabulary.id,
              search_term: keyword_term.meta_key.id[0, 3]
            },
            user_id: admin_user.id
          )

          expect(assigns[:keyword_terms]).to eq [keyword_term]
        end
      end
    end
  end

  describe '#edit' do
    it 'assigns @vocabulary and @keyword_term correctly' do
      get(
        :edit,
        { vocabulary_id: vocabulary.id, id: keyword_term.id },
        user_id: admin_user.id
      )

      expect(assigns[:vocabulary]).to eq vocabulary
      expect(assigns[:keyword_term]).to eq keyword_term
      expect(response).to render_template :edit
    end
  end

  describe '#update' do
    let(:params) do
      {
        vocabulary_id: vocabulary.id,
        id: keyword_term.id,
        keyword_term: {
          term: 'updated term'
        }
      }
    end

    it "updates the keyword_term's term" do
      put :update, params, user_id: admin_user.id

      expect(keyword_term.reload.term).to eq 'updated term'
      expect(flash[:success]).to eq flash_message(:update, :success)
    end

    it 'redirects to admin keyword_term path' do
      put :update, params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(
        admin_vocabulary_keyword_terms_path(vocabulary)
      )
    end
  end

  describe '#new' do
    before { get :new, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'assigns @vocabulary correctly' do
      expect(assigns[:vocabulary]).to eq vocabulary
    end

    it 'assigns @keyword_term correctly' do
      expect(assigns[:keyword_term]).to be_an_instance_of(KeywordTerm)
      expect(assigns[:keyword_term]).to be_new_record
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    let(:keyword_term_params) do
      {
        vocabulary_id: vocabulary.id,
        keyword_term: {
          term: 'new keyword_term',
          meta_key_id: meta_key.id
        }
      }
    end

    it 'creates a new keyword_term' do
      expect { post :create, keyword_term_params, user_id: admin_user.id }
        .to change { KeywordTerm.count }.by(1)
    end

    it 'redirects to admin keyword_terms path' do
      post :create, keyword_term_params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(
        admin_vocabulary_keyword_terms_path(vocabulary)
      )
      expect(flash[:success]).not_to be_empty
    end

    it 'displays success message' do
      post :create, keyword_term_params, user_id: admin_user.id

      expect(flash[:success]).not_to be_empty
    end
  end

  describe '#destroy' do
    it 'destroys the keyword_term' do
      vocabulary and keyword_term

      expect do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: keyword_term.id },
          user_id: admin_user.id
        )
      end.to change { KeywordTerm.count }.by(-1)
    end

    context 'when delete was successful' do
      before do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: keyword_term.id },
          user_id: admin_user.id
        )
      end

      it 'redirects to admin keyword_terms path' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(
          admin_vocabulary_keyword_terms_path(vocabulary)
        )
      end

      it 'displays success message' do
        expect(flash[:success]).to be_present
      end
    end

    context 'when keyword_terms does not exist' do
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
    I18n.t type, scope: "flash.actions.#{action}", resource_name: 'Keyword term'
  end
end
