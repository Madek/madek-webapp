require "spec_helper"
require "spec_helper_feature"
require 'spec_helper_feature_shared'

feature "Meta Data - Instititutional Groups" do

  # NOTE: These tests are run with `Settings.zhdk_integration = true`
  #       and will FAIL otherwise!
  before :each do
    puts 'INFO: zhdk_integration is ' + (Settings.zhdk_integration ? 'ON' : 'OFF')
    expect(Settings.zhdk_integration).to eq true
  end
  
  scenario "LDAP-Groups are filtered in backend", browser: :headless do
    
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
    input= field.find('input')
    
    # When I type 'Verteilerliste' in the multiselect inside.
    input.set('Verteilerliste'); sleep 1
    # Then the autocomplete has no matches
    expect(field.first('ul.ui-autocomplete li', visible: false)).to be
    
    # When I type '.studierende' in the multiselect inside.
    input.set('.studierende'); sleep 1
    # Then the autocomplete has no matches
    expect(field.first('ul.ui-autocomplete li', visible: false)).to be
    
  end
  
  scenario "Selecting Groups doesn't select Children", browser: :firefox do
    
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
    input= field.find('input')
    # and I type 'Departement Design' in the multiselect inside.
    input.set('Departement Design'); sleep 1
    
    # The first Result is 'Departement Design (DDE)', I select it and save.
    line= field.find('ul.ui-autocomplete').all('li').first
    line.click
    submit_form
    
    # Back on the MediaEntry page, I find the metadata heading 'Bereich ZHdK'
    # and remember the box around it
    mdata= find('.media-data-title', text: 'Bereich ZHdK').find(:xpath, './/..')
    
    # The content of it is *exactly* 'Departement Design (DDE.alle)'.
    expect(mdata.find('.media-data-content').text)
      .to eq 'Departement Design (DDE)'
    
  end
end
