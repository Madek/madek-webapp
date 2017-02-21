require_relative './_shared'

feature 'Dashboard: New Collection' do
  describe 'Action: new' do

    scenario 'Modal dialog title error' do
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
end
