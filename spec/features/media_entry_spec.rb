require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
  end

  scenario '#create: upload and publish' do
    # go to dashboard and import button
    visit my_dashboard_path
    within('.ui-body-title-actions') do
      find('.button-primary').click
    end
    expect(current_path).to eq '/entries/new'

    # select file and submit
    within('.app-body') do
      image_path = Rails.root.join('spec', 'data', 'images', 'grumpy_cat.jpg')
      attach_file('media_entry_media_file', File.absolute_path(image_path))
      submit_form
    end

    # unpublished entry was created
    within('#app') do
      alert = find('.ui-alert.warning')
      expect(alert).to have_content 'Entry is not published yet!'
    end

    # TODO: (when validation) add some needed meta data

    # publish it
    click_on 'Publish!'

    # it was published
    alert = find('#app-alerts .success')
    expect(alert).to have_content 'Entry was published!'

  end

  scenario '#delete', browser: :firefox do
    visit media_entry_path \
      create :media_entry_with_image_media_file,
             creator: @user, responsible_user: @user

    # visit media_entry_path(media_entry)

    # main actions has a delete button with a confirmation:
    within '.ui-body-title-actions' do
      confirmation = find('.icon-trash').click
      expect(confirmation).to eq 'Are you sure you want to delete this?'
      accept_confirm
    end

    # redirects to user dashboard:
    expect(current_path).to eq my_dashboard_path

  end

end
