require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Explore Catalog' do

  describe 'Action: index' do

    it 'is rendered for public' do
      visit explore_path
      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Schlagworte zu Inhalt und Motiv'
      ) do
        click_on 'Weitere anzeigen'
      end
      expect(page).to have_css('h1', text: 'Catalog / Schlagworte zu Inhalt und Motiv')
      expect(page).to have_content('Fotografie')
      expect(page).to have_content('Diplomarbeit')
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login

      visit explore_path
      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Schlagworte zu Inhalt und Motiv'
      ) do
        click_on 'Weitere anzeigen'
      end
      expect(page).to have_css('h1', text: 'Catalog / Schlagworte zu Inhalt und Motiv')
      expect(page).to have_content('Fotografie')
      expect(page).to have_content('Diplomarbeit')
    end

  end

end
