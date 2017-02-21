require_relative './_shared'

feature 'Dashboard: New Collection' do
  describe 'Action: create' do

    scenario 'Modal dialog ok' do
      login
      open_new_set
      within '.modal' do
        enter_set_title('Test Create Set 3x')
        ok
      end
      expect(page).to have_content 'Test Create Set'
      collection = Collection.by_title('Test Create Set')[0]
      expect(collection.responsible_user_id).to eq(@user.id)
      expect(current_path).to eq collection_path(collection)
    end

  end
end
