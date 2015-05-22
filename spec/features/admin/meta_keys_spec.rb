require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Meta Keys' do
  let(:meta_key_with_keywords) { MetaKey.with_type('MetaDatum::Keywords').first }
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Sorting meta keys by ID by default' do
    visit admin_meta_keys_path

    expect(find_field('sort_by')[:value]).to eq 'id'
  end

  scenario 'Sorting meta keys by Name part' do
    visit admin_meta_keys_path

    select 'Name part', from: 'Sort by'
    click_button 'Apply'

    expect(page).to have_select('sort_by', selected: 'Name part')
  end

  context 'Editing' do
    scenario 'Proper values for selects' do
      visit edit_admin_meta_key_path(meta_key_with_keywords)

      expect(page).to have_select(
        'Vocabulary',
        selected: meta_key_with_keywords.vocabulary_id)
      expect(page).to have_select(
        'Meta datum object type',
        selected: meta_key_with_keywords.meta_datum_object_type)
      expect(page).to have_select(
        'Keywords alphabetical order',
        selected: selected_value_from_boolean(
          meta_key_with_keywords.keywords_alphabetical_order)
      )
    end
  end

  def selected_value_from_boolean(value)
    value == true ? 'Yes' : 'No'
  end
end
