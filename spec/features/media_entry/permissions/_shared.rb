module MediaEntryPermissionsShared

  private

  def open_permission_editable
    visit permissions_media_entry_path(@entry)
    @node_form = find('[name="ui-rights-management"]')

    @node_people = subject_row(
      @node_form, I18n.t(:permission_subject_title_users))
    @node_groups = subject_row(
      @node_form, I18n.t(:permission_subject_title_groups))

    expect(subject_items(@node_people).length).to be 0
    expect(subject_items(@node_groups).length).to be 0
    # this is hidden on show when empty:
    expect(subject_row(@node_form, I18n.t(:permission_subject_title_apiapps)))
      .to be nil

    @node_form.click_on(I18n.t(:permissions_table_edit_btn))

    # router works:
    expect(current_path).to eq edit_permissions_media_entry_path(@entry)

    # now its visible:
    @node_apiapps = subject_row(
      @node_form, I18n.t(:permission_subject_title_apiapps))
    expect(subject_items(@node_apiapps).length).to be 0
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
    header = form.first('table thead', text: title)
    header.find(:xpath, '../../..') if header
  end

  def subject_items(node)
    node.all('tbody tr')
  end

  def add_subject_with_permission(node, name, permission_name)
    autocomplete_and_choose_first(node, name)
    node.find('tbody tr', text: name)
      .find("[name='#{permission_name}']")
      .click
  end

  def interact_with_page_so_we_dont_look_like_spammers
    # NOTE: needs at least *some* interaction with the page,
    # or the browser will ignore us (because it looks like a spam popup)
    find('h2', text: I18n.t(:permissions_responsible_user_title)).click
  end

end
