require 'spec_helper'

describe Admin::PeopleController do
  let!(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with HTTP 200 status code' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'loads the first page of people into @people' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(assigns(:people)).to eq Person.first(16)
    end

    describe 'filtering people' do
      context 'by first name' do
        it "returns users containing 'xxx' in first name" do
          person_1 = create :person, first_name: 'test1xxx'
          person_2 = create :person, first_name: 'test2xxx'
          person_3 = create :person, first_name: 'test3xxx'

          get :index, { search_term: 'xxx' }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns(:people)).to match_array [person_1, person_2, person_3]
        end
      end

      context 'with user' do
        it 'returns only people with user' do
          get :index, { with_user: 1 }, user_id: admin_user.id

          expect(response).to be_success
          expect(assigns(:people)).to match_array Person.with_user
        end
      end
    end
  end

  describe '#show' do
    before do
      @person = create :person
    end

    it 'responds with HTTP 200 status code' do
      get :show, { id: @person.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: @person.id }, user_id: admin_user.id

      expect(response).to render_template(:show)
    end

    it 'loads the proper person into @person' do
      get :show, { id: @person.id }, user_id: admin_user.id

      expect(assigns[:person]).to eq @person
    end
  end

  describe '#edit' do
    before do
      @person = create :person
    end

    it 'responds with HTTP 200 status code' do
      get :edit, { id: @person.id }, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'render the edit template and assigns the person to @person' do
      get :edit, { id: @person.id }, user_id: admin_user.id

      expect(response).to render_template(:edit)
      expect(assigns[:person]).to eq @person
    end
  end

  describe '#update' do
    before do
      @person = create :person
    end

    it 'redirects to admin person show page' do
      patch(
        :update,
        { id: @person.id, person: { first_name: 'test' } },
        user_id: admin_user.id
      )

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_person_path(@person))
    end

    it 'updates the person' do
      patch(
        :update,
        { id: @person.id, person: { first_name: 'test' } },
        user_id: admin_user.id
      )

      expect(flash[:success]).to eq 'The person has been updated.'
      expect(@person.reload.first_name).to eq 'test'
    end

    it 'displays error message when something went wrong' do
      patch :update, { id: @person.id }, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(edit_admin_person_path(@person))
      expect(flash[:error]).not_to be_nil
    end
  end

  describe '#create' do
    it 'redirects to admin people path after successfuly created person' do
      post :create, { person: attributes_for(:person) }, user_id: admin_user.id

      expect(response).to have_http_status(302)
      expect(response).to redirect_to(admin_people_path)
      expect(flash[:success]).to eq(
        'The person has been created.')
    end

    it 'creates a person' do
      expect do
        post :create, { person: attributes_for(:person) }, user_id: admin_user.id
      end.to change { Person.count }.by(1)
    end

    context 'when validation failed' do
      it "renders 'new' template" do
        post :create, nil, user_id: admin_user.id

        expect(response).to be_success
        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
        expect(flash[:error]).to be_present
      end

      it 'assigns @person with previously given values' do
        attributes = { first_name: 'example_name' }
        post :create, { person: attributes }, user_id: admin_user.id

        expect(assigns[:person].first_name).to eq 'example_name'
      end
    end
  end

  describe '#destroy' do
    let!(:person) { create :person }

    it 'redirects to admin people path after succesful destroy' do
      delete :destroy, { id: person.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_people_path)
      expect(flash[:success]).to eq 'The person has been deleted.'
    end

    it 'destroys the person' do
      expect do
        delete :destroy, { id: person.id }, user_id: admin_user.id
      end.to change { Person.count }.by(-1)
    end
  end
end
