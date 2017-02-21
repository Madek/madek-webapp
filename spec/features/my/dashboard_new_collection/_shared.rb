require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

def login
  @user = User.find_by(login: 'normin')
  sign_in_as @user.login
end

def check_on_dashboard
  expect(current_path).to eq my_dashboard_path
end

def check_on_dialog
  # expect(current_path).to eq my_new_collection_path
  expect(page).to have_content 'Set erstellen'
  expect(page).to have_content 'Abbrechen'
end

def open_new_set
  visit '/my'
  check_on_dashboard
  find('a', text: I18n.t(:dashboard_create_collection_btn)).click
  check_on_dialog
end

def enter_set_title(title)
  find('input[name=collection_title]').set(title)
end

def cancel
  find('a', text: 'Abbrechen').click
end

def ok
  find('button', text: 'Set erstellen').click
end
