require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Page: Explore' do

  # NOTE: re-enable/fix after explore feature is complete
  describe 'Action: index' do

    it 'is rendered for public', browser: false do
      visit explore_path
      expect(page.status_code).to eq 200
    end

    it 'is rendered for a logged in user' do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit explore_path
    end

    it 'no header login button for root page' do
      visit root_path
      expect(page).to have_no_css(
        '.ui-header-user',
        text: I18n.t(:user_menu_login_btn))
    end

    it 'header login button for explore page' do
      visit explore_path
      find('.ui-header-user', text: I18n.t(:user_menu_login_btn))
    end

    it 'proper order of context_keys in catalog and navigation' do
      app_setting = AppSetting.first
      app_setting.catalog_context_keys = \
        ContextKey
        .joins(:meta_key)
        .joins('INNER JOIN keywords ON keywords.meta_key_id = meta_keys.id')
        .where(meta_keys: { meta_datum_object_type: 'MetaDatum::Keywords' })
        .uniq
        .take(3)
        .map(&:id)
      app_setting.save!

      labels = app_setting.catalog_context_keys.map do |ck_id|
        ck = ContextKey.find(ck_id)
        ck.label.presence || ck.meta_key.label
      end

      visit explore_path
      within '.ui-side-navigation-item', text: 'Catalog' do
        expect(all('.ui-side-navigation-lvl2 a').map(&:text)).to be == labels
      end
      within '.ui-resources-holder', text: 'Catalog' do
        expect(all('.ui-thumbnail-meta-title').map(&:text)).to be == labels
      end
    end

    pending 'shows simple lists of Entries, Collections and FilterSets' \
      'with links to their indexes'

  end

  describe 'Explore content on login page' do

    it 'contains latest entries sorted by created_at DESC', browser: false do
      visit root_path
      expect(page.status_code).to eq 200
      within '.ui-resources-holder', text: I18n.t(:home_page_new_contents) do
        expect(
          all("a[type='media-entry']").map { |el| el['href'].split('/').last }
        ).to be == \
          MediaEntry
          .viewable_by_public
          .reorder(created_at: :desc)
          .limit(12)
          .map(&:id)
      end
    end

  end

end
