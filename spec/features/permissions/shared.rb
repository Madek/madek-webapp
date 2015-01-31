module Features
  module Permissions
    module Shared
      def add_group_permission_for_resource(permission)
        group =
          Group.joins(:users).where("groups_users.user_id = ?", @current_user.id).first ||
          FactoryGirl.create(:group)
        group.users << @current_user unless group.users.include?(@current_user)
        grouppermissions =
          Grouppermission.where(media_resource_id: @resource.id).where(group_id: group.id).first ||
          Grouppermission.create(media_resource_id: @resource.id, group_id: group.id)
        grouppermissions.update_attributes permission => true
      end

      def add_resource_to_group
        assert_modal_visible
        find('.ui-modal input.ui-search-input').set(@set.title)
        check "parent_resource_#{@set.id}"
        find('.ui-modal button.primary-button').click
        assert_modal_not_visible
        expect(page).to have_css('.ui-alert.confirmation')
      end

      def add_user_permission_to_resource(permission, login = nil, n = nil)
        user = login ? User.find_by!(login: login) : @current_user
        resource = n ? @resources[n] : @resource
        permissions =
          resource.userpermissions.where(user_id: user.id).first ||
          resource.userpermissions.create(user: user)
        permissions.update_attributes(permission => true)
      end

      def add_user_permission_to_set(permission)
        permissions =
          @set.userpermissions.where(user_id: @current_user.id).first ||
          @set.userpermissions.create(user: @current_user)
        permissions.update_attributes permission => true
      end

      def check_permission_for(login_or_name, permission)
        user = User.find_by!(login: login_or_name) rescue Group.find_by!(name: login_or_name)
        within "tr[data-name='#{user}']" do
          check permission.to_s
        end
      end

      def expect_checked_permission_for(login_or_name, permission)
        user = User.find_by!(login: login_or_name) rescue Group.find_by!(name: login_or_name)
        expect(find("tr[data-name='#{user}'] input[name='#{permission}']")).to be_checked
      end

      def expect_confirmation_alert
        expect(page).to have_css('.ui-alert.confirmation')
      end

      def expect_group_to_have_permission(name, permission, state = true)
        group = Group.find_by!(name: name)
        group_permission = Grouppermission.where(media_resource_id: @my_first_media_entry.id).where(group_id: group.id).first
        expect(group_permission.send(permission)).to be state
      end

      def expect_mixed_permission_for(login, permission)
        user = User.find_by!(login: login)
        check_box = find("tr[data-name='#{user}'] input[name='#{permission}']")
        expect(check_box).not_to be_checked
        expect(check_box[:value]).to eq('mixed')
      end

      def expect_no_permissions_for_group(name)
        group = Group.find_by!(name: name)
        expect(
          @my_first_media_entry.grouppermissions.joins(:group).where("groups.name = ?", name).count
        ).to be_zero
      end

      def expect_no_permissions_for_user(login)
        user = User.find_by!(login: login)
        expect(
          @my_first_media_entry.userpermissions.joins(:user).where("users.login = ?", login).count
        ).to be_zero
      end

      def expect_not_checked_permission_for(login, permission)
        user = User.find_by!(login: login)
        expect(find("tr[data-name='#{user}'] input[name='#{permission}']")).not_to be_checked
      end

      def expect_select_for_permission_presets
        expect(page).to have_selector(
          "tr[data-name='#{@user_with_userpermissions.name}'] select.ui-rights-role-select option",
          minimum: 1
        )
      end

      def expect_set_to_include_resource
        expect(@set.child_media_resources.reload.pluck(:id)).to include(@resource.id)
      end

      def expect_submit_button
        expect(page).to have_css('button', text: 'Speichern')
      end

      def expect_user_to_have_permission(login, permission, state = true, n = nil)
        user = User.find_by!(login: login)
        resource = n ? @resources[n] : @my_first_media_entry
        user_permission = Userpermission.where(media_resource_id: resource.id).where(user_id: user.id).first
        expect(user_permission.send(permission)).to be state
      end

      def expect_view_page_of_resource_permissions
        assert_exact_url_path '/permissions/edit'
        expect(current_url).to match /_action\=view/
        expect(current_url).to match /media_resource_id\=#{@my_first_media_entry.id}/
      end

      def find_not_owned_resource_with_no_other_permissions
        @resource = User.find_by(login: 'petra').media_entries.first
        @resource.update_attributes download: false, edit: false, manage: false, view: false
        @resource.userpermissions.clear
        @resource.grouppermissions.clear
      end

      def find_not_owned_set_with_to_permissions_and_no_children
        @set = User.find_by(login: 'petra').media_sets.first
        @set.update_attributes download: false, edit: false, manage: false, view: false
        @set.userpermissions.clear
        @set.grouppermissions.clear
        @set.child_media_resources.clear
      end

      def find_owned_resource_with_permissions_for(login)
        @user_with_userpermissions = User.find_by(login: login)
        @resource = MediaResource.where(user_id: @current_user.id).joins(:userpermissions).
          where('userpermissions.user_id = ?', @user_with_userpermissions.id).first
      end

      def find_owned_resource_with_no_other_permissions
        @resource = @current_user.media_resources.first
        @resource.userpermissions.clear
        @resource.grouppermissions.clear
        @resource.update_attributes view: false, edit: false, manage: false, download: false
      end

      def create_not_owned_resource_with_file_with_no_permissions
        @petra = User.find_by(login: 'petra')
        @resource = FactoryGirl.create :media_entry_with_image_media_file, user: @petra
        @resource.update_attributes download: false, edit: false, manage: false, view: false
        @resource.userpermissions.clear
        @resource.grouppermissions.clear
      end

      def open_edit_permissions_page
        open_view_permissions_page
        click_link 'edit-permissions'
      end

      def open_view_permissions_page
        open_resource_actions
        click_link 'view_permissions_of_resource'
      end

      def remove_permissions_from_my_first_media_entry(owner_permissions = false)
        @my_first_media_entry = @current_user.media_entries.reorder(:created_at,:id).first
        @my_first_media_entry.userpermissions.clear
        @my_first_media_entry.grouppermissions.clear

        if owner_permissions
          @my_first_media_entry.update_attributes(view: false, edit: false, manage: false, download: false)
        end
      end

      def remove_from_permissions(name)
        within find('table.ui-rights-group td', text: name) do
          find('a.ui-rights-remove').click
        end
      end

      def setup_departments_with_ldap_references
        InstitutionalGroup.create([
          {
            institutional_group_id: "4396.studierende",
            institutional_group_name: "DKV_FAE_BAE.studierende",
            name: "Bachelor Vermittlung von Kunst und Design"
          },
          {
            institutional_group_id: "56663.dozierende",
            institutional_group_name: "DDE_FDE_VID.dozierende",
            name: "Vertiefung Industrial Design"
          }
        ])
      end
    end
  end
end
