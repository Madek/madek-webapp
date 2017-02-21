require_relative './_shared'

feature 'Dashboard: New Collection' do
  describe 'Action: new' do

    scenario 'Modal dialog cancel' do
      login
      open_new_set
      within '.modal' do
        enter_set_title('Test')
        cancel
      end
      check_on_dashboard
    end

  end
end
