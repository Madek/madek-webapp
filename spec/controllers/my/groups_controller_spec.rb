require 'spec_helper'

describe My::GroupsController do
  let(:user) { create :user }
  let(:group) { create :group }

  describe '#show' do
    context 'when user has access to the group' do
      before do
        group.users << user
        get(:show, params: { id: group.id }, session: { user_id: user.id })
      end

      it 'responds with 200 status code' do
        expect(response).to be_successful
        expect(response).to have_http_status(200)
      end

      it 'renders template' do
        expect(response).to render_template(:show)
      end
    end

    context 'when user has no access to the group' do
      it 'raises error' do
        expect { get(:show, params: { id: group.id }, session: { user_id: user.id }) }
          .to raise_error(Errors::ForbiddenError)
      end
    end

    context 'when previous id was passed' do
      it 'redirects to current group page' do
        previous_obj = create(:group)
        current_obj = create(:group)

        previous_obj.merge_to(current_obj)

        get(:show, params: { id: previous_obj.id }, session: { user_id: user.id })

        expect(response).to redirect_to(my_group_path(current_obj))
      end
    end

    context 'when previous id does not exist for some reason' do
      it 'raises ActiveRecord::RecordNotFound error' do
        previous_obj = create(:group)
        current_obj = create(:group)

        previous_obj.merge_to(current_obj)
        current_obj.previous.first.update_column(:group_id, SecureRandom.uuid)

        expect { get(:show, params: { id: previous_obj.id }, session: { user_id: user.id }) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#create' do
    context 'when name is not used' do
      it 'creates a new group' do
        post :create,
             params: { group: { name: 'new group' } },
             session: { user_id: user.id }

        expect(response).to redirect_to my_groups_path
      end
    end

    context 'when name is used' do
      it 'raises an error' do
        expect do
          post :create,
               params: { group: { name: group.name } },
               session: { user_id: user.id }
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#destroy' do
    context 'when user is the last member' do
      it 'destroys the group' do
        group.users << user

        expect do
          delete :destroy,
                 params: { id: group.id },
                 session: { user_id: user.id }
        end.to change { Group.count }.by(-1)
      end
    end

    context 'when group has more members' do
      it 'prevents from destroying' do
        group.users << user
        group.users << create(:user)

        expect do
          delete :destroy,
                 params: { id: group.id },
                 session: { user_id: user.id }
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

  describe 'adding a member' do
    let(:new_member) { create(:user) }
    let(:member_params) do
      {
        group: {
          users: {
            user.id => 'true',
            new_member.id => 'true'
          }
        }
      }
    end

    context 'when group is an internal group' do
      it 'adds a member to the group' do
        group.users << user

        expect do
          put :update,
              params: { id: group.id }.merge(member_params),
              session: { user_id: user.id }
        end.to change { group.users.count }.by(1)

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(my_groups_path)
      end
    end

    context 'when group is an external group' do
      it 'denies access' do
        external_group = create :group, type: :InstitutionalGroup
        external_group.users << user

        expect do
          put :update,
              params: { id: external_group.id }.merge(member_params),
              session: { user_id: user.id }
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

  describe 'removing the member' do
    let(:member_to_remove) { create(:user) }
    let(:member_params) do
      {
        group: {
          users: {
            user.id => 'true'
          }
        }
      }
    end

    context 'when group is an internal group' do
      it 'removes a member from the group' do
        group.users << [user, member_to_remove]

        expect do
          put :update,
              params: { id: group.id }.merge(member_params),
              session: { user_id: user.id }
        end.to change { group.users.count }.by(-1)

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(my_groups_path)
      end
    end

    context 'when group is an external group' do
      it 'denies access' do
        external_group = create :group, type: :InstitutionalGroup
        external_group.users << [user, member_to_remove]

        expect do
          put :update,
              params: { id: external_group.id }.merge(member_params),
              session: { user_id: user.id }
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

end
