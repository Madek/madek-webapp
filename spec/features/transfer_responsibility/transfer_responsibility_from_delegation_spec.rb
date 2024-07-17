require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'transfer responsibility from delegation' do

  before :each do
    @user1 = create(:user)
    @group1 = create(:group)
    @group1.users << @user1

    @delegation1 = create(:delegation, name: 'Super')
    @delegation1.users << @user1
    
    @delegation2 = create(:delegation, name: 'Mega')
    @delegation2.groups << @group1

    @user2 = create(:user)
  end

  scenario 'batch process for media entries with mixed responsibility' do
    # 1) responsible: user1
    media_entry1 = create_media_entry(@user1, title: 'Kohl')
    # 2) responsible: delegation1 (user is direct member)
    media_entry2 = create_media_entry(@user1, title: 'Birne')
    update_responsible_delegation(media_entry2, @delegation1)
    # 3) responsible: delegation2 (user is member via group)
    media_entry3 = create_media_entry(@user1, title: 'Apfel')
    update_responsible_delegation(media_entry3, @delegation2)

    parent = create_collection(@user1)
    add_all_to_parent([media_entry1, media_entry2, media_entry3], parent)

    login_user(@user1)
    open_resource(parent)

    # Dialog for resource where user is directly responsible

    select_media_entries([media_entry1])
    click_dropdown
    check_partial_dropdown(media_entries_transfer_responsibility: { count: 1 })
    click_batch_action(:media_entries_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 1 Medieneintrag übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        "#{@user1.to_s}"
      ].join("\n")
    expect(page).to have_text "Sie, #{@user1.to_s}, behalten folgende Berechtigungen:"
    click_cancel_button
    select_media_entries([media_entry1]) # (deselect)

    # Dialog for resource where delegation is responsible

    select_media_entries([media_entry2])
    click_dropdown
    check_partial_dropdown(media_entries_transfer_responsibility: { count: 1 })
    click_batch_action(:media_entries_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 1 Medieneintrag übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        "Super (Verantwortungs-Gruppe)"
      ].join("\n")
    expect(page).to have_text "Super (Verantwortungs-Gruppe) behält folgende Berechtigungen:"
    click_cancel_button
    select_media_entries([media_entry2]) # (deselect)

    # Dialog for all 3 resources

    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(media_entries_transfer_responsibility: { count: 3 })
    click_batch_action(:media_entries_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 3 Medieneinträge übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        'Mega (Verantwortungs-Gruppe) für 1 Medieneintrag', 
        'Super (Verantwortungs-Gruppe) für 1 Medieneintrag', 
        "#{@user1.to_s} für 1 Medieneintrag"
      ].join("\n")
    expect(page).to have_text 'Die bisher Verantwortlichen behalten folgende Berechtigungen:'

    # Apply
    
    choose_user(@user2)
    click_submit_button

    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(media_entries_transfer_responsibility: { count: 0, active: false })
    check_partial_dropdown(media_entries_permissions: { count: 3 })
  end

  scenario 'batch process for collections with mixed responsibility' do
    # 1) responsible: user1
    collection1 = create_collection(@user1, title: 'Sammlung 1')
    # 2) responsible: delegation1 (user is direct member)
    collection2 = create_collection(@user1, title: 'Sammlung 2')
    update_responsible_delegation(collection2, @delegation1)
    # 3) responsible: delegation2 (user is member via group)
    collection3 = create_collection(@user1, title: 'Sammlung 3')
    update_responsible_delegation(collection3, @delegation2)

    parent = create_collection(@user1)
    add_all_to_parent([collection1, collection2, collection3], parent)

    login_user(@user1)
    open_resource(parent)

    # Dialog for resource where user is directly responsible

    select_collections([collection1])
    click_dropdown
    check_partial_dropdown(collections_transfer_responsibility: { count: 1 })
    click_batch_action(:collections_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 1 Set übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        "#{@user1.to_s}"
      ].join("\n")
    expect(page).to have_text "Sie, #{@user1.to_s}, behalten folgende Berechtigungen:"
    click_cancel_button
    select_collections([collection1]) # (deselect)

    # Dialog for resource where delegation is responsible

    select_collections([collection2])
    click_dropdown
    check_partial_dropdown(collections_transfer_responsibility: { count: 1 })
    click_batch_action(:collections_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 1 Set übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        "Super (Verantwortungs-Gruppe)"
      ].join("\n")
    expect(page).to have_text "Super (Verantwortungs-Gruppe) behält folgende Berechtigungen:"
    click_cancel_button
    select_collections([collection2]) # (deselect)

    # Dialog for all 3 resources

    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(collections_transfer_responsibility: { count: 3 })

    click_batch_action(:collections_transfer_responsibility)
    expect(page).to have_text 'Verantwortlichkeit für 3 Sets übertragen'
    expect(page).to have_text [
        'Bisher verantwortlich', 
        'Mega (Verantwortungs-Gruppe) für 1 Set', 
        'Super (Verantwortungs-Gruppe) für 1 Set', 
        "#{@user1.to_s} für 1 Set"
      ].join("\n")
    expect(page).to have_text 'Die bisher Verantwortlichen behalten folgende Berechtigungen:'
    
    choose_user(@user2)
    click_submit_button

    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(collections_transfer_responsibility: { count: 0, active: false })
    check_partial_dropdown(collections_permissions: { count: 3 })
  end
end
