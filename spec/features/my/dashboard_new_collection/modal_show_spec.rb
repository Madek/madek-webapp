require_relative './_shared'

feature 'Dashboard: New Collection' do

  describe 'Action: new' do
    scenario 'Modal dialog is shown' do
      login
      open_new_set
    end

  end
end
