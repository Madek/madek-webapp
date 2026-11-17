module MediaEntryPermissionsShared

  private

  def open_permission_editable
    visit permissions_media_entry_path(@entry)
    @node_form = find('[name="ui-rights-management"]')

    check_initial_rows

    # start editing
    @node_form.click_on(I18n.t(:permissions_table_edit_btn))

    # router works:
    expect(current_path).to eq edit_permissions_media_entry_path(@entry)

    # on edit, API client row is always visible:
    @node_apiapps = subject_row(
      @node_form, I18n.t(:permission_subject_title_apiapps))
    expect(subject_items(@node_apiapps).length).to be 0
  end

  def check_initial_rows
    user_permissions_count = @entry.user_permissions.count
    group_permissions_count = @entry.group_permissions.count
    api_client_permissions_count = @entry.api_client_permissions.count
    @node_people = subject_row(
      @node_form, I18n.t(:permission_subject_title_users_or_delegations))
    @node_groups = subject_row(
      @node_form, I18n.t(:permission_subject_title_groups))

    expect(subject_items(@node_people).length).to be user_permissions_count
    expect(subject_items(@node_groups).length).to be group_permissions_count

    # on show, API client row is hidden when empty:
    if api_client_permissions_count < 1
      expect(subject_row(@node_form, I18n.t(:permission_subject_title_apiapps)))
        .to be nil
    else
      @node_api_clients = subject_row(
        @node_form, I18n.t(:permission_subject_title_apiapps))

      expect(subject_items(@node_api_clients)).to be api_client_permissions_count
    end
  end

  def permission_types
    %w(
      get_metadata_and_previews
      get_full_size
      edit_metadata
      edit_permissions
    )
  end

  def subject_row(form, title)
    header = form.all('thead td', exact_text: title)[0]
    header.find(:xpath, '../../../..') if header
  end

  def subject_items(node)
    node.all('tbody tr')
  end

  def add_subject_with_permission(node, name, permission_name)
    unless row = node.all('tbody tr', text: name)[0]
      autocomplete_and_choose_first(node, name)
      row = node.find('tbody tr', text: name)
    end
    row.find("[name='#{permission_name}']")
      .click
  end

  def interact_with_page_so_we_dont_look_like_spammers
    # NOTE: needs at least *some* interaction with the page,
    # or the browser will ignore us (because it looks like a spam popup)
    find('h2', text: I18n.t(:permissions_responsible_user_and_responsibility_group_title)).click
  end

  def expect_permission(perm, name, bool)
    expect(perm[name]).to be bool, lambda do
       "expected permission `#{name}` to be `#{bool}`, got `#{!bool}`!"
    end
  end

end
