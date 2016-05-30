require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Dashboard: New Collection' do

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

  describe 'Action: new' do

    scenario 'Modal dialog is shown', browser: :firefox do
      login
      open_new_set
    end

    scenario 'Modal dialog cancel', browser: :firefox do
      login
      open_new_set
      within '.modal' do
        enter_set_title('Test')
        cancel
      end
      check_on_dashboard
    end

    scenario 'Modal dialog title error', browser: :firefox do
      login
      open_new_set
      within '.modal' do
        enter_set_title('')
        ok
        check_on_dialog
        expect(page).to have_content 'Titel ist ein Pflichtfeld'
        cancel
      end
      check_on_dashboard
      expect(page).to have_no_content 'Titel ist ein Pflichtfeld'
    end

  end

  describe 'Action: create' do

    scenario 'Modal dialog ok', browser: :firefox do
      login
      open_new_set
      within '.modal' do
        enter_set_title('Test Create Set')
        ok
      end
      collection = Collection.by_title('Test Create Set')[0]
      expect(collection.responsible_user_id).to eq(@user.id)
      expect(current_path).to eq collection_path(collection)
      expect(page).to have_content 'Test Create Set'
    end

  end

end
