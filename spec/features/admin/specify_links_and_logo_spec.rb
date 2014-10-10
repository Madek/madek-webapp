require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin - Configure footer and logo' do
  background { sign_in_as 'Adam' }

  scenario 'Configuring footer links' do
    add_some_links_to_footer
    expect_those_links_at_path '/my'
    expect_those_links_at_path '/media_resources'
    expect_those_links_at_path '/media_entries/65'
  end

  scenario 'Specifying a logo for the instance' do
    configure_logo_for_instance
    expect_logo_setting
  end

  def add_some_links_to_footer
    visit '/app_admin/settings/footer_links/edit'
    @links = {
      'THE SOMEWHERE LINK' => 'http://somwhere.com',
      'THE NOWHERE LINK' => 'http://nowhere.com'
    }
    find('textarea#app_settings_extra_yaml_footer_links').set(@links.to_yaml)
    find("*[type='submit']").click
  end

  def configure_logo_for_instance
    @logo_url = 'http://somewhere.com/some_logo.png'
    visit '/app_admin/settings/logo_url/edit'
    find("input#app_settings_logo_url").set(@logo_url)
    find("*[type=submit]").click
  end

  def expect_logo_setting
    visit '/my'
    expect(page).to have_css(".app-header .ui-header-brand img[src='#{@logo_url}']")
  end

  def expect_those_links_at_path(path)
    visit path
    within '.app-footer' do
      @links.each do |text, href|
        find("a[href='#{href}']", text: text)
      end
    end
  end
end
