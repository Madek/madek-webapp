require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Media Entry - Managing Confidential Links' do
  background do
    @user = User.find_by(login: 'normin')
    @entry = create :media_entry_with_image_media_file,
                    creator: @user, responsible_user: @user
  end

  scenario 'Listing Confidential Links' do
    confidential_links = 3.times.map do
      create(:confidential_link, user: @user, resource: @entry)
    end

    sign_in_as @user.login
    visit media_entry_path(@entry)

    within find '.ui-body-title-actions .ui-dropdown' do
      find('a', text: I18n.t(:resource_action_more_actions)).click
      find(
        'a',
        text: I18n.t(:resource_action_media_entry_manage_confidential_links))
        .click
    end

    data_table = confidential_links.map do |cfl|
      [
        slice_token(cfl.token),
        cfl.description,
        I18n.t(:confidential_links_list_no_expiry),
        I18n.t(:confidential_links_list_show_url),
        'icon: fa fa-ban'
      ]
    end.reverse

    expect(displayed_ui).to eq(data_table)
  end

  scenario 'Adding a new Confidential Link valid forever' do
    description = Faker::Hipster.sentence

    sign_in_as @user.login
    visit media_entry_path(@entry)

    within find '.ui-body-title-actions .ui-dropdown' do
      find('a', text: I18n.t(:resource_action_more_actions)).click
      find(
        'a',
        text: I18n.t(:resource_action_media_entry_manage_confidential_links))
        .click
    end

    click_link I18n.t(:confidential_links_list_new_button)

    fill_in 'confidential_link[description]', with: description
    uncheck I18n.t(:confidential_links_create_set_expiration_date)
    expect { submit_form }.to change { ConfidentialLink.count }.by 1

    check_secret_url
    expect(displayed_details).to include(description)
    expect(displayed_details)
      .to include(I18n.t(:confidential_links_list_no_expiry))
  end

  scenario 'Adding a new Confidential Link valid for 30 days w/o description' do
    sign_in_as @user.login
    visit media_entry_path(@entry)

    within find '.ui-body-title-actions .ui-dropdown' do
      find('a', text: I18n.t(:resource_action_more_actions)).click
      find(
        'a',
        text: I18n.t(:resource_action_media_entry_manage_confidential_links))
        .click
    end

    click_link I18n.t(:confidential_links_list_new_button)
    # dont check the checkbox, we expect it to be checked by default
    expect { submit_form }.to change { ConfidentialLink.count }.by 1

    check_secret_url
    expect(displayed_details).to include(
      I18n.t(:confidential_links_list_no_description))
    expect(displayed_details).to include('in einem Monat')
  end

  scenario 'Canceling adding process' do
    sign_in_as @user.login
    visit confidential_links_media_entry_path(@entry)

    click_link I18n.t(:confidential_links_list_new_button)
    click_link I18n.t(:confidential_links_create_cancel)

    expect(current_path).to eq confidential_links_media_entry_path(@entry)
  end

  scenario 'Revoking' do
    cf_link = create :confidential_link, user: @user, resource: @entry

    sign_in_as @user.login
    visit confidential_links_media_entry_path(@entry)

    row = find('.ui-resources-holder table tr', text: slice_token(cf_link.token))

    accept_confirm do
      within(row) { submit_form }
    end

    expect(current_path).to eq confidential_links_media_entry_path(@entry)
    cf_link.reload
    expect(cf_link.revoked).to be true

    sleep(1)
    expect(displayed_ui(revoked: true)).to eq [
      [
        slice_token(cf_link.token),
        cf_link.description,
        I18n.t(:confidential_links_list_no_expiry),
        I18n.t(:confidential_links_list_show_url),
        ''
      ]
    ]
  end

end

private

def displayed_ui(revoked: false)
  table_index = revoked ? 1 : 0
  table = all('.ui-resources-holder table')[table_index]
  table.all('tbody tr').map do |tr|
    fields = tr.all('td')
    btn_icon = revoked ? '' : "icon: #{fields.last.find('button i')[:class]}"
    # NOTE: ignore the created timestamp, we cant know the UI text!
    [
      fields[0].text, fields[1].text, fields[3].text,
      fields[4].text, btn_icon
    ]
  end
end

def displayed_details
  within('[data-react-class="UI.Views.Shared.ConfidentialLinkShow"]') do
    all('table tbody tr').last.all('td').map(&:text).reject(&:blank?)
  end
end

def check_secret_url
  within('[data-react-class="UI.Views.Shared.ConfidentialLinkShow"]') do
    secret_url = find('samp.code').text
    token = secret_url.split('/').last

    expect(secret_url.split('/').last.length).to be_between(31, 32)
    expect(secret_url).to end_with(
      show_by_confidential_link_media_entry_path(@entry, token))
    expect(secret_url).to start_with 'http://'
  end
end

def slice_token(token)
  token.slice(0, 6) + '…'
end
