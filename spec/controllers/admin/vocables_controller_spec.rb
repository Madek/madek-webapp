require 'spec_helper'

describe Admin::VocablesController do
  let(:admin_user) { create :admin_user }
  let(:vocabulary) { create :vocabulary_for_vocables }
  let(:vocable) { create :vocable, meta_key: vocabulary.meta_keys.first }

  describe '#index' do
    before { get :index, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'responds with HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @vocables correctly' do
      expect(assigns[:vocables]).to eq [vocable]
    end

    describe 'filtering' do
      context 'by id' do
        it 'returns a proper vocable' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: vocable.id },
            user_id: admin_user.id
          )

          expect(assigns[:vocables]).to eq [vocable]
        end
      end

      context 'by term' do
        it 'returns a proper vocable' do
          get(
            :index,
            { vocabulary_id: vocabulary.id, search_term: vocable.term[0, 2] },
            user_id: admin_user.id
          )

          expect(assigns[:vocables]).to eq [vocable]
        end
      end

      context 'by meta key' do
        it 'returns a proper vocable' do
          get(
            :index,
            {
              vocabulary_id: vocabulary.id,
              search_term: vocable.meta_key.id[0, 3]
            },
            user_id: admin_user.id
          )

          expect(assigns[:vocables]).to eq [vocable]
        end
      end
    end
  end

  describe '#edit' do
    it 'assigns @vocabulary and @vocable correctly' do
      get(
        :edit,
        { vocabulary_id: vocabulary.id, id: vocable.id },
        user_id: admin_user.id
      )

      expect(assigns[:vocabulary]).to eq vocabulary
      expect(assigns[:vocable]).to eq vocable
      expect(response).to render_template :edit
    end
  end

  describe '#update' do
    let(:params) do
      {
        vocabulary_id: vocabulary.id,
        id: vocable.id,
        vocable: {
          term: 'updated term'
        }
      }
    end

    it "updates the vocable's term" do
      put :update, params, user_id: admin_user.id

      expect(vocable.reload.term).to eq 'updated term'
    end

    it 'redirects to admin vocable path' do
      put :update, params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_vocabulary_vocables_path(vocabulary))
    end
  end

  describe '#new' do
    before { get :new, { vocabulary_id: vocabulary.id }, user_id: admin_user.id }

    it 'assigns @vocabulary correctly' do
      expect(assigns[:vocabulary]).to eq vocabulary
    end

    it 'assigns @vocable correctly' do
      expect(assigns[:vocable]).to be_an_instance_of(Vocable)
      expect(assigns[:vocable]).to be_new_record
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    let(:vocable_params) do
      {
        vocabulary_id: vocabulary.id,
        vocable: {
          term: 'new vocable',
          meta_key_id: vocabulary.meta_keys.first.id
        }
      }
    end

    it 'creates a new vocable' do
      expect { post :create, vocable_params, user_id: admin_user.id }
        .to change { Vocable.count }.by(1)
    end

    it 'redirects to admin vocables path' do
      post :create, vocable_params, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_vocabulary_vocables_path(vocabulary))
      expect(flash[:success]).not_to be_empty
    end

    it 'displays success message' do
      post :create, vocable_params, user_id: admin_user.id

      expect(flash[:success]).not_to be_empty
    end
  end

  describe '#destroy' do
    it 'destroys the vocable' do
      vocabulary and vocable

      expect do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: vocable.id },
          user_id: admin_user.id
        )
      end.to change { Vocable.count }.by(-1)
    end

    context 'when delete was successful' do
      before do
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: vocable.id },
          user_id: admin_user.id
        )
      end

      it 'redirects to admin vocables path' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_vocabulary_vocables_path(vocabulary))
      end

      it 'displays success message' do
        expect(flash[:success]).to be_present
      end
    end

    context 'when delete raised an error' do
      before do
        allow_any_instance_of(Vocable).to receive(:destroy!).and_raise('error')
        delete(
          :destroy,
          { vocabulary_id: vocabulary.id, id: vocable.id },
          user_id: admin_user.id
        )
      end

      it 'redirects to admin vocabularies path' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(admin_vocabulary_vocables_path(vocabulary))
      end

      it 'displays error message' do
        expect(flash[:success]).not_to be_present
        expect(flash[:error]).to eq 'error'
      end
    end
  end
end
