require 'spec_helper'

describe My::GroupsController do
  let(:user) { create :user }
  let(:group) { create :group }

  describe '#create' do
    context 'when name is not used' do
      it 'creates a new group' do
        post :create,
             { group: { name: 'new group' } },
             user_id: user.id

        expect(response).to redirect_to my_groups_path
      end
    end

    context 'when name is used' do
      it 'raises an error' do
        expect do
          post :create,
               { group: { name: group.name } },
               user_id: user.id
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
                 { id: group.id },
                 user_id: user.id
        end.to change { Group.count }.by(-1)
      end
    end

    context 'when group has more members' do
      it 'prevents from destroying' do
        group.users << user
        group.users << create(:user)

        expect do
          delete :destroy,
                 { id: group.id },
                 user_id: user.id
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
              { id: group.id }.merge(member_params),
              user_id: user.id
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
              { id: external_group.id }.merge(member_params),
              user_id: user.id
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
              { id: group.id }.merge(member_params),
              user_id: user.id
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
              { id: external_group.id }.merge(member_params),
              user_id: user.id
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

end
