module TransferResponsibilityShared

  def click_clear_user
    find('form[name="transfer_responsibility"]').find(
      'a.icon-close').click
  end

  def check_submit(active)
    button = find('form[name="transfer_responsibility"]').find(
      'button', text: I18n.t(:transfer_responsibility_submit))
    expect(button[:disabled]).to eq(active ? nil : 'true')
  end

  def add_all_to_parent(resources, parent)
    resources.each do |resource|
      resource.parent_collections << parent
    end
  end

  def unpublish(media_entry)
    media_entry.is_published = false
    media_entry.save!
    media_entry.reload
  end

  def give_all_permissions(resource, user)
    permissions = {
      user: user,
      get_metadata_and_previews: true,
      get_full_size: true,
      edit_metadata: true,
      edit_permissions: true
    }
    resource.user_permissions.create!(permissions)
    resource.save!
    resource.reload
  end

  def open_resource(resource)
    visit(send("#{resource.class.name.underscore}_path", resource))
  end

  def user_to_string(user)
    person = user.person
    "#{person.first_name} #{person.last_name} (#{person.pseudonym})"
  end

  def check_error_message(message_key)
    find('form[name="transfer_responsibility"]').find(
      '.ui-alerts', text: I18n.t(message_key))
  end

  def check_no_permissions(user, resource)
    expect(resource.user_permissions.where(user: user).length).to eq(0)
  end

  def check_permissions(user, resource, type, view, download, edit, manage)
    permissions = resource.user_permissions.where(user: user).first
    if type == MediaEntry
      expect(permissions[:get_metadata_and_previews]).to eq(view)
      expect(permissions[:get_full_size]).to eq(download)
      expect(permissions[:edit_metadata]).to eq(edit)
      expect(permissions[:edit_permissions]).to eq(manage)
    elsif type == Collection
      expect(permissions[:get_metadata_and_previews]).to eq(view)
      expect(download).to eq(nil)
      expect(permissions[:edit_metadata_and_relations]).to eq(edit)
      expect(permissions[:edit_permissions]).to eq(manage)
    else
      raise 'Type not supported: ' + type
    end
  end

  def check_on_dashboard_after_loosing_view_rights
    expect(current_path).to eq('/my')
  end

  def wait_until_form_disappeared
    wait_until do
      all('form[name="transfer_responsibility"]').empty?
    end
  end

  def click_submit_button
    find('form[name="transfer_responsibility"]').find(
      'button', text: I18n.t(:transfer_responsibility_submit)).click
  end

  def click_cancel_button
    find('form[name="transfer_responsibility"]').find(
      'a', text: I18n.t(:transfer_responsibility_cancel)).click
  end

  def choose_user(user)
    form = find('form[name="transfer_responsibility"]')
    autocomplete_and_choose_first(form, user.login)
  end

  def check_checkbox(type, id, active)
    within('form[name="transfer_responsibility"]') do
      if id == :download && type != MediaEntry
        expect(active).to eq(nil)
        expect(page).to have_no_selector(
          "input[name=\"transfer_responsibility[permissions][#{id}]\"]")
      else
        element = find(
          "input[name=\"transfer_responsibility[permissions][#{id}]\"]")
        expected = active ? 'true' : nil
        expect(element[:checked]).to eq(expected)
      end
    end
  end

  def click_checkbox(id)
    within('form[name="transfer_responsibility"]') do
      find("input[name=\"transfer_responsibility[permissions][#{id}]\"]").click
    end
  end

  def check_checkboxes(type, view, download, edit, manage)
    check_checkbox(type, :view, view)
    check_checkbox(type, :download, download)
    check_checkbox(type, :edit, edit)
    check_checkbox(type, :manage, manage)
  end

  def open_permissions(resource)
    visit send("permissions_#{resource.class.name.underscore}_path", resource)
  end

  def click_transfer_link
    find('.tab-content')
      .find('a', text: I18n.t(:permissions_transfer_responsibility_link))
      .click
  end

  def check_responsible_and_link(user, visible)
    within '.tab-content' do

      find('form[name="ui-rights-management"]').find(
        '.ui-info-box', text: user_to_string(user))

      expect(page).to have_selector(
        'a',
        text: I18n.t(:permissions_transfer_responsibility_link),
        count: (visible ? 1 : 0))
    end
  end

  def create_user
    FactoryGirl.create(:user)
  end

  def create_collection(user, title = nil)
    collection = FactoryGirl.create(
      :collection,
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    if title
      MetaDatum::Text.create!(
        collection: collection,
        string: title,
        meta_key: meta_key_title,
        created_by: user)
    end
    collection
  end

  def create_media_entry(user, title = nil)
    media_entry = FactoryGirl.create(
      :media_entry,
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    FactoryGirl.create(
      :media_file_for_image,
      media_entry: media_entry)
    if title
      MetaDatum::Text.create!(
        media_entry: media_entry,
        string: title,
        meta_key: meta_key_title,
        created_by: user)
    end
    media_entry
  end

  def login_user(user)
    sign_in_as(user.login, user.password)
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end
end
