shared_examples 'user permissions with delegation' do |model_name|
  let(:user) { create(:user) }

  context 'when uuid comes from a delegation' do
    let(:delegation) { create(:delegation) }
    let(:resource) { create(model_name, responsible_user: user) }
    let(:other_resource) { create(model_name) }

    context 'and resource_type key in subject params is missing' do
      it 'raises ActiveRecord::InvalidForeignKey error' do
        update_params = {
          id: resource.id,
          model_name => {
            user_permissions: [
              {
                subject: { uuid: delegation.id },
                get_metadata_and_previews: true
              }
            ]
          }
        }

        expect do
          put :permissions_update,
              params: update_params,
              session: { user_id: user.id }
        end.to raise_error ActiveRecord::InvalidForeignKey
      end
    end

    it 'adds proper user permissions' do
      update_params = {
        id: resource.id,
        model_name => {
          user_permissions: [
            {
              subject: { uuid: delegation.id, resource_type: 'Delegation' },
              get_metadata_and_previews: true
            }
          ],
          public_permission: {
            get_metadata_and_previews: true,
            get_full_size: false
          }
        }
      }

      put :permissions_update,
          params: update_params,
          session: { user_id: user.id }

      user_permissions = resource.user_permissions
      user_permission = user_permissions.first

      expect(user_permissions.count).to eq(1)
      expect(user_permission.delegation).to eq(delegation)
      expect(user_permission.user).to be_nil
      expect(user_permission.get_metadata_and_previews).to be true
    end

    it "does not take into consideration #{model_name}_id key in subject params" do
      update_params = {
        id: resource.id,
        model_name => {
          user_permissions: [
            {
              subject: {
                uuid: delegation.id,
                resource_type: 'Delegation',
                "#{model_name}_id": other_resource.id
              },
              get_metadata_and_previews: true
            }
          ],
          public_permission: {
            get_metadata_and_previews: true,
            get_full_size: false
          }
        }
      }

      put :permissions_update,
          params: update_params,
          session: { user_id: user.id }

      user_permissions = resource.user_permissions
      user_permission = user_permissions.first

      expect(user_permissions.count).to eq(1)
      expect(other_resource.user_permissions.count).to be_zero
      expect(user_permission.delegation).to eq(delegation)
      expect(user_permission.user).to be_nil
      expect(user_permission.get_metadata_and_previews).to be true
    end
  end
end
