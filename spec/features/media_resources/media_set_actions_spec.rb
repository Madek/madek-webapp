require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature "MediaResource" do
  before :each do
    @current_user = sign_in_as 'normin'
    # Set "Ausstellungen"
    @id = '351ffad4-bddc-48b7-981b-50a56a7998ea'
  end

  scenario 'setting cover picture for a media set', browser: :headless do
    expect(MediaSet.find(@id).cover(@current_user).id).to_not eq("81880474-ce44-4006-861c-dd7743b94005")
    visit media_set_path @id
    click_on_text "Weitere Aktionen"
    click_on_text "Titelbild"
    # Entry "Ausstellung Photo 4"
    within('tr[data-id="81880474-ce44-4006-861c-dd7743b94005"]') do
      choose('cover')
    end
    find('.primary-button[type="submit"]').click
    wait_until{page.evaluate_script(%<$.active>) == 0}
    visit media_set_path @id 
    expect(MediaSet.find(@id).cover(@current_user).id).to eq("81880474-ce44-4006-861c-dd7743b94005")
  end
  
  scenario 'setting highlights for a media set', browser: :headless do
    visit media_set_path @id
    click_on_text "Weitere Aktionen"
    click_on_text "Inhalte hervorheben"
    # Entry "Ausstellung Photo 4"
    within('tr[data-id="81880474-ce44-4006-861c-dd7743b94005"]') do
      find('input[type="checkbox"]').set(true)
    end
    find('.primary-button[type="submit"]').click
    wait_until{page.evaluate_script(%<$.active>) == 0}
    visit media_set_path @id
    within('ul.ui-featured-entries-list') do
      id = find('img')['src']
      expect(id[17..-18]).to eq("81880474-ce44-4006-861c-dd7743b94005")
    end
  end
end
