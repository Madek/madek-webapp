require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Showing previews" do
  scenario "Switching between, minature, grid and list", browser: :headless do
    @current_user = sign_in_as "Normin"
    visit media_resources_path
    find("#miniature-view").click
    element_with_title_has_the_active_class("Miniatur-Ansicht")
    resources_list_has_class("miniature")

    find("#grid-view").click
    element_with_title_has_the_active_class("Raster-Ansicht")
    resources_list_has_class("grid")

    find("#list-view").click
    element_with_title_has_the_active_class("Listen-Ansicht")
    resources_list_has_class("list")

    find("#tile-view").click
    element_with_title_has_the_active_class("Kachel-Ansicht")
    resources_list_has_class("tiles")
    resources_list_has_class("vertical")
  end
  
  def element_with_title_has_the_active_class(title)
    expect(find("a[title='#{title}'].active")).to be
  end
  
  def resources_list_has_class(_class)
    expect(find("#ui-resources-list.#{_class}")).to be
  end
end 
