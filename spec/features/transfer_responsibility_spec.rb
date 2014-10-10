require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","features","shared.rb"
include Features::Shared

feature "Transfer responsibility" do

  scenario "Transferring one media resource as an owner" do

    @current_user = sign_in_as "normin"
    remove_all_permissions_from_user_first_media_entry
    visit_user_first_media_entry
    @resource = @media_resource= @media_entry= get_current_media_resource
    open_the_transfer_responsibility_page
    fill_in "user", with: "[petra]"
    submit_form

    assert_owner_media_ressource "petra"
    assert_user_permissions "Normin", { view: true,
                                        download: true,
                                        edit: true,
                                        manage: true }

  end

  scenario "Transferring a media resource where I am not the owner should not be possible" do

    @current_user = sign_in_as "normin"
    remove_all_permissions_from_user_first_media_entry
    visit_user_first_media_entry
    @resource = @media_resource= @media_entry= get_current_media_resource
    open_the_transfer_responsibility_page
    fill_in "user", with: "[petra]"
    submit_form

    assert_owner_media_ressource "petra"
    assert_user_permissions "Normin", { view: true,
                                        download: true,
                                        edit: true,
                                        manage: true }

    visit media_resource_path(@resource)
    click_on_text "Weitere Aktionen"
    expect(page).not_to have_selector(".button", text: "Verantwortlichkeit übertragen")

  end

  scenario "Setting custom permissions for owner while transfering to other person", browser: :headless do

    @current_user = sign_in_as "normin"
    remove_all_permissions_from_user_first_media_entry
    visit_user_first_media_entry
    @resource = @media_resource= @media_entry= get_current_media_resource
    open_the_transfer_responsibility_page
    fill_in "user", with: "[petra]"

    ensure_status_for_permission "view", "true"
    ensure_status_for_permission "download", "false"
    ensure_status_for_permission "edit", "true"
    ensure_status_for_permission "manage", "false"

    submit_form

    assert_owner_media_ressource "petra"
    assert_user_permissions "Normin", { view: true,
                                        download: false,
                                        edit: true,
                                        manage: false }

  end

  scenario "Transfering responsibility as uberadmin" do

    @current_user = sign_in_as "adam"

    # I switch to uberadmin modus
    find("#user-action-button").click
    find("a#switch-to-uberadmin").click

    # I remove all permissions from Normin's first media_entry
    @media_entry = User.find_by_login("normin").media_entries.reorder(:created_at,:id).first
    @media_entry.userpermissions.clear
    @media_entry.grouppermissions.clear

    # I visit the path of Normin's first media entry
    visit media_resource_path User.find_by_login("normin").media_entries.reorder(:created_at,:id).first

    @resource = @media_resource= @media_entry= get_current_media_resource

    open_the_transfer_responsibility_page
    fill_in "user", with: "[petra]"
    submit_form

    assert_owner_media_ressource "petra"
    assert_user_permissions "Normin", { view: true,
                                        download: true,
                                        edit: true,
                                        manage: true }

  end

  def remove_all_permissions_from_user_first_media_entry
    my_first_media_entry = @current_user.media_entries.reorder(:created_at,:id).first
    my_first_media_entry.userpermissions.clear
    my_first_media_entry.grouppermissions.clear
  end

  def open_the_transfer_responsibility_page
    find("#resource-action-button").click
    find("#view_permissions_of_resource").click
    find("#transfer-responsibilities").click
  end

  def assert_owner_media_ressource login
    expect(@media_resource.reload.user).to be== User.find_by_login(login.downcase)
  end

  def assert_user_permissions login, hash_of_permissions
    user = User.find_by_login login
    permissions = \
      @resource.userpermissions.where(user_id: user.id).first  \
      || @resource.userpermissions.create(user: user)

    hash_of_permissions.each_pair do |k, v|
      expect(permissions.send(k)).to eq v
    end
  end

  def ensure_status_for_permission permission, pvalue
    input_element = find("input[name='userpermission[#{permission}]']", match: :first)

    begin
      input_element.click
      done = 
        case pvalue
        when "false"
          not input_element.checked?
        when "true"
          input_element.checked?
        else
          raise "you should never gotten here"
        end
    end while not done
  end

end
