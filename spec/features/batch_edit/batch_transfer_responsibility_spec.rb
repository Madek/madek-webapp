require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Batch transfer responsibility spec' do
  let(:beta_tester_group) { Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID) }
  before(:each) do
    @user_1 = create(:user, password: 'password')
    @user_2 = create(:user, password: 'password')
    @user_1.groups << beta_tester_group
    @user_2.groups << beta_tester_group
  end

  it 'successfully updates responsible user for all Entries' do
    @resource_1 = FactoryBot.create(
      :media_entry_with_title,
      title: 'Test Entry 1',
      responsible_user: @user_1)
    @resource_2 = FactoryBot.create(
      :media_entry_with_title,
      title: 'Test Entry 2',
      responsible_user: @user_1)

    sign_in_as @user_1.login

    # select and choose action
    visit my_dashboard_section_path(:content_media_entries)
    select_all_in_box_and_choose_from_menu(
      'Verantwortlichkeit von Medieneinträgen übertragen'
    )

    el = find("form[name='transfer_responsibility']")
    autocomplete_and_choose_first(el, subject_search_name(@user_2))
    click_on 'Übertragen'
    find(".ui-alert.success",
         text: "Sie haben für 2 Medieneinträge die Verantwortlichkeit erfolgreich übertragen.")
    logout

    sign_in_as @user_2.login
    visit my_dashboard_section_path(:content_media_entries)
    expect(page).to have_content(@resource_1.title)
    expect(page).to have_content(@resource_2.title)

    visit my_dashboard_section_path(:notifications)
    expect(page).to have_content(
      "Verantwortlichkeit von #{@resource_1.title} wurde von #{@user_1} an Sie übertragen."
    )
    expect(page).to have_content(
      "Verantwortlichkeit von #{@resource_2.title} wurde von #{@user_1} an Sie übertragen."
    )
  end

  it 'successfully updates responsible user for all Collections' do
    @resource_1 = FactoryBot.create(
      :collection_with_title,
      title: 'Test Set 1',
      responsible_user: @user_1)
    @resource_2 = FactoryBot.create(
      :collection_with_title,
      title: 'Test Set 2',
      responsible_user: @user_1)

    sign_in_as @user_1.login

    # select and choose action
    visit my_dashboard_section_path(:content_collections)
    select_all_in_box_and_choose_from_menu(
      'Verantwortlichkeit von Sets übertragen'
    )

    el = find("form[name='transfer_responsibility']")
    autocomplete_and_choose_first(el, subject_search_name(@user_2))
    click_on 'Übertragen'
    find(".ui-alert.success",
         text: "Sie haben für 2 Sets die Verantwortlichkeit erfolgreich übertragen.")
    logout

    sign_in_as @user_2.login
    visit my_dashboard_section_path(:content_collections)
    expect(page).to have_content(@resource_1.title)
    expect(page).to have_content(@resource_2.title)

    visit my_dashboard_section_path(:notifications)
    expect(page).to have_content(
      "Verantwortlichkeit von #{@resource_1.title} wurde von #{@user_1} an Sie übertragen."
    )
    expect(page).to have_content(
      "Verantwortlichkeit von #{@resource_2.title} wurde von #{@user_1} an Sie übertragen."
    )
  end
end

def select_all_in_box_and_choose_from_menu(text)
  click_select_all_on_first_page
  within(page.find('.ui-polybox')) do
    within('.ui-filterbar') do
      find('.dropdown-toggle, .ui-drop-toggle', text: 'Aktionen').click
      find('.dropdown-menu a', text: text).click
    end
  end
end

def subject_search_name(subject)
  subject.class == User ? subject.login : subject_name(subject)
end
