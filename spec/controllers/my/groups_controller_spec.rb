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

  describe '#add_member' do
    context 'when group is an internal group' do
      it 'adds a member to the group' do
        new_user = create(:user)
        group.users << user

        expect do
          post :add_member,
               { id: group.id, member: { login: new_user.login } },
               user_id: user.id
        end.to change { group.users.count }.by(1)

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(edit_my_group_path(group))
      end
    end

    context 'when group is an external group' do
      it 'denies access' do
        external_group = create :group, type: :InstitutionalGroup
        external_group.users << user
        new_user = create(:user)

        expect do
          post :add_member,
               { id: external_group.id, member: { login: new_user.login } },
               user_id: user.id
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

  describe '#remove_member' do
    context 'when group is an internal group' do
      it 'removes a member from the group' do
        new_user = create(:user)
        group.users << [user, new_user]

        expect do
          delete :remove_member,
                 { id: group.id, member_id: new_user.id },
                 user_id: user.id
        end.to change { group.users.count }.by(-1)

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(edit_my_group_path(group))
      end
    end

    context 'when group is an external group' do
      it 'denies access' do
        external_group = create :group, type: :InstitutionalGroup
        new_user = create(:user)
        external_group.users << [user, new_user]

        expect do
          delete :remove_member,
                 { id: external_group.id, member_id: new_user.id },
                 user_id: user.id
        end.to raise_error(Errors::ForbiddenError)
      end
    end
  end

end
