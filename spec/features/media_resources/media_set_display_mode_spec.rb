require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature "MediaResource" do
  scenario "switching display mode should be saved", browser: :headless do
    @current_user = sign_in_as 'normin'
    # Set "Ausstellungen"
    id = '351ffad4-bddc-48b7-981b-50a56a7998ea'
    visit media_set_path id
    
    #tile view
    find('#tile-view').click
    expect(find('#ui-resources-list')[:class]).to include("tiles")
    visit media_set_path id
    expect(find('#ui-resources-list')[:class]).to include("tiles")
    
    #minature view
    find('#miniature-view').click
    expect(find('#ui-resources-list')[:class]).to include("miniature")
    visit media_set_path id
    expect(find('#ui-resources-list')[:class]).to include("miniature")

    #grid view
    find('#grid-view').click
    expect(find('#ui-resources-list')[:class]).to include("grid")
    visit media_set_path id
    expect(find('#ui-resources-list')[:class]).to include("grid")

    #grid view
    find('#list-view').click
    expect(find('#ui-resources-list')[:class]).to include("list")
    visit media_set_path id
    expect(find('#ui-resources-list')[:class]).to include("list")
  end
end
