require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'MediaResource' do
  background do
    @current_user = sign_in_as 'normin'
    # Set "Ausstellungen"
    @id = '351ffad4-bddc-48b7-981b-50a56a7998ea'
  end

  scenario 'setting cover picture for a media set', browser: :firefox do
    expect(MediaSet.find(@id).cover(@current_user).id).to_not eq('81880474-ce44-4006-861c-dd7743b94005')
    visit media_set_path(@id)
    click_on_text 'Weitere Aktionen'
    click_on_text 'Titelbild'
    # Entry "Ausstellung Photo 4"
    within('tr[data-id="81880474-ce44-4006-861c-dd7743b94005"]') do
      choose('cover')
    end
    click_primary_action_of_modal
    wait_for_ajax
    assert_modal_not_visible
    expect(MediaSet.find(@id).cover(@current_user).id).to eq('81880474-ce44-4006-861c-dd7743b94005')
  end

  scenario 'setting highlights for a media set', browser: :firefox do
    visit media_set_path @id
    click_on_text 'Weitere Aktionen'
    click_on_text 'Inhalte hervorheben'
    # Entry 'Ausstellung Photo 4'
    within('tr[data-id="81880474-ce44-4006-861c-dd7743b94005"]') do
      find('input[type="checkbox"]').set(true)
    end
    click_primary_action_of_modal
    wait_for_ajax
    assert_modal_not_visible
    within('ul.ui-featured-entries-list') do
      img_id = find('img')[:src].split('/')[-2]
      expect(img_id).to eq('81880474-ce44-4006-861c-dd7743b94005')
    end
  end
end
