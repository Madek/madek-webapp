require 'spec_helper'

describe Admin::GroupsController do
  let(:admin_user) { create :admin_user }

  describe '#index' do
    it 'responds with status code 200' do
      get :index, nil, user_id: admin_user.id

      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    describe 'filtering/sorting groups' do
      context 'by type' do
        it "returns groups with 'Group' type" do
          get :index, { type: 'group' }, user_id: admin_user.id

          expect(assigns(:groups)) \
            .to match_array(Group.page(1).per(25).where(type: 'Group'))
        end

        it "returns groups with 'InstitutionalGroup' type" do

          get :index, { type: 'institutional_group' }, user_id: admin_user.id

          expect(assigns(:groups)).to match_array(Group.page(1).per(25) \
            .where(type: 'InstitutionalGroup'))
        end

      end

      context 'by name' do
        it "returns groups with 'test' in their name" do
          group1 = create :group, name: 'test1'
          group2 = create :group, name: 'test2'
          group3 = create :group, name: 'test3'

          get(
              :index,
              { search_terms: 'test', sort_by: 'name' },
              user_id: admin_user.id
          )

          expect(assigns(:groups)).to match_array [group1, group2, group3]
        end
      end

      context 'by text search ranking' do
        it "returns groups found by text search ranking with 'test'" do
          group1 = create :group, name: 'test one'
          group2 = create :group, name: 'test two'
          group3 = create :group, name: 'test three'

          get(
            :index,
            { search_terms: 'test', sort_by: 'text_rank' },
            user_id: admin_user.id
          )

          expect(assigns(:groups)).to match_array [group1, group2, group3]
        end

        it 'returns error when search_terms are missing' do
          get(
            :index,
            { search_terms: '', sort_by: 'text_rank' },
            user_id: admin_user.id
          )
          expect(flash[:error]).to eq 'Search term must not be blank!'
        end
      end

      context 'by trigram search ranking' do
        it "returns groups found by trigram search ranking with 'test'" do
          group1 = create :group, name: 'test1'
          group2 = create :group, name: 'test2'
          group3 = create :group, name: 'test3'

          get(
            :index,
            { search_terms: 'test', sort_by: 'trgm_rank' },
            user_id: admin_user.id
          )

          expect(assigns(:groups)).to match_array [group1, group2, group3]
        end

        it 'returns error when search_terms are missing' do
          get(
            :index,
            { search_terms: '', sort_by: 'trgm_rank' },
            user_id: admin_user.id
          )
          expect(flash[:error]).to eq 'Search term must not be blank!'
        end
      end
    end
  end

  describe '#show' do
    let!(:group) { create :group }

    it 'responds with status code 200' do
      get :show, { id: group.id }, user_id: admin_user.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      get :show, { id: group.id }, user_id: admin_user.id
      expect(response).to render_template(:show)
    end

    it 'loads the proper group into @group' do
      get :show, { id: group.id }, user_id: admin_user.id
      expect(assigns[:group]).to eq group
    end
  end

  describe '#update' do
    let!(:group) { create :group }

    it 'redirects to group#show after successful update' do
      patch(
        :update,
        { id: group.id, group: { name: 'NEW NAME' } },
        user_id: admin_user.id
      )

      expect(response).to have_http_status(302)
      expect(response).to redirect_to admin_group_path(assigns(:group))
    end

    it 'updates the group' do
      patch(
        :update,
        { id: group.id, group: { name: 'NEW NAME' } },
        user_id: admin_user.id
      )

      expect(flash[:success]).to eq 'The group has been updated.'
      expect(group.reload.name).to eq 'NEW NAME'
    end

    context 'failed valdations' do
      it 'displays error messages and redirects' do
        patch(
          :update,
          { id: group.id, group: { name: '' } },
          user_id: admin_user.id
        )

        expect(response).to have_http_status(302)
        expect(response).to redirect_to edit_admin_group_path(assigns(:group))
        expect(flash[:error]).not_to be_nil
      end
    end
  end

  describe '#create' do
    it 'redirects to group#show after successful create' do
      post :create, { group: attributes_for(:group) }, user_id: admin_user.id

      expect(response).to redirect_to admin_group_path(assigns(:group))
      expect(flash[:success]).to eq 'A new group has been created.'
    end

    it 'creates a group' do
      expect do
        post :create, { group: attributes_for(:group) }, user_id: admin_user.id
      end.to change { Group.count }.by(1)
    end

    context 'failed validation' do
      it 'displays errors and redirects' do
        post :create, nil, user_id: admin_user.id

        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_admin_group_path(assigns(:group))
        expect(flash[:error]).not_to be_nil
      end
    end
  end

  describe '#destroy' do
    let!(:group) { create :group }

    it 'redirects to admin groups path after a successful destroy' do
      delete :destroy, { id: group.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_groups_path)
      expect(flash[:success]).to eq 'The group has been deleted.'
    end

    it 'destroys the group' do
      expect do
        delete :destroy, { id: group.id }, user_id: admin_user.id
      end.to change { Group.count }.by(-1)
    end
  end

  describe '#add_user' do
    let!(:group) { create :group }
    let!(:user)  { create :user  }

    it 'redirects to group page after successful addition' do
      post :add_user, { id: group.id, user_id: user.id }, user_id: admin_user.id

      expect(response).to redirect_to(admin_group_path(group))
      expect(flash[:success]).to eq "The user <b>#{user.login}</b> has been added."
    end

    it 'adds user to selected group' do
      expect do
        post :add_user, { id: group.id, user_id: user.id }, user_id: admin_user.id
      end.to change { group.users.count }.by(1)
    end

    it 'displays an error if user is already a member' do
      post :add_user, { id: group.id, user_id: user.id }, user_id: admin_user.id
      post :add_user, { id: group.id, user_id: user.id }, user_id: admin_user.id
      expect(response).to redirect_to(admin_group_path(group))
      expect(flash[:error]) \
        .to eq "The user <b>#{user.login}</b> already belongs to this group."
    end

    it 'displays error messages if something goes wrong' do
      post :add_user, { id: group.id, user_id: '123' }, user_id: admin_user.id
      expect(response).to redirect_to(admin_group_path(group))
      expect(flash[:error]).to_not be_nil
    end
  end

  describe '#merge_to' do
    let!(:department1) do
      dep = build :group, type: 'InstitutionalGroup'
      dep.save(validate: false)
      dep
    end
    let!(:department2) do
      dep = build :group, type: 'InstitutionalGroup'
      dep.save(validate: false)
      dep
    end
    let!(:group)       { create :group }

    it 'merges two institutional groups' do
      post(
        :merge_to,
        { id: department1.id, id_receiver: department2.id },
        user_id: admin_user.id
      )
      expect(response).to redirect_to(admin_group_path(department2))
      expect(flash[:success]).to eq 'The group has been merged.'
    end

    it "displays error messages if target group isn't istitutional group" do
      post(
        :merge_to,
        { id: department1.id, id_receiver: group.id },
        user_id: admin_user.id
      )
      expect(response).to redirect_to(admin_group_path(department1))
      expect(flash[:error]).not_to be_nil
    end
  end
end
