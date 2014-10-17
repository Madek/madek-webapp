require "spec_helper"
require "spec_helper_feature"
require 'spec_helper_feature_shared'

feature "Meta Data - Instititutional Groups" do
  
  scenario "Selecting Groups doesn't select Children", browser: :headless do

    # As Normin, I make a new `MediaEntry`
    @user= sign_in_as 'normin'
    @media_entry= FactoryGirl
      .create :media_entry_with_image_media_file, user: @user
    
    # I edit the entry
    visit media_entry_path(@media_entry)
    click_on_text "Weitere Aktionen"
    click_on_text "Metadaten editieren"
    # and switch to the 'ZHdK' tab.
    find('[data-context-id="zhdk_bereich"] a').click
    sleep 0.1
    
    # I go to the first Form Field for `meta_datum_institutional_groups`
    field= find('fieldset[data-type="meta_datum_institutional_groups"]')
    input= field.find('input.institutional_affiliation_autocomplete_search')
    # and I type 'DDE' in the multiselect inside.
    input.set('DDE')
    
    # The first Result is 'Departement Design (DDE)', I select it and save.
    line= field.find('.department-autocomplete').all('li').first
    expect(line.text).to eq 'Departement Design (DDE)'
    line.click
    submit_form
    
    # Back on the MediaEntry page, I find the metadata heading 'Bereich ZHdK'
    # and remember the box around it
    mdata= find('.media-data-title', text: 'Bereich ZHdK').find(:xpath,'.//..')
    
    # The content of it is *exactly* 'Departement Design (DDE.alle)'.
    expect(mdata.find('.media-data-content').text)
      .to eq 'Departement Design (DDE.alle)'
    
  end

end
