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

    describe 'dealing with empty catalog context keys (1st level)' do
      it 'doesn\'t show catalog section at all if the count of all is 0' do
        context_key = create(:context_key, meta_key: create(:meta_key_keywords))
        app_setting = AppSetting.first
        app_setting.update_attributes!(catalog_context_keys: [context_key.id],
                                       catalog_title: 'Catalog Title')
        media_entry = create(:media_entry,
                             get_metadata_and_previews: false,
                             get_full_size: false)
        media_entry.meta_data << create(:meta_datum_keywords,
                                        meta_key: context_key.meta_key)

        visit explore_path
        expect(page).not_to have_content 'Catalog Title'
      end
    end

    describe 'dealing with entries of different media_types' do
      before :example do
        @meta_key = \
          MetaKey.find_by_id('test:keywords') || create(:meta_key_keywords)
        @context_key = create(:context_key, meta_key: @meta_key)
        @keyword = create(:keyword, meta_key: @meta_key)
        app_setting = AppSetting.first
        app_setting.update_attributes!(catalog_context_keys: [@context_key.id],
                                       catalog_title: 'Catalog Title')

        media_entry_with_image = create(:media_entry_with_image_media_file,
                                        get_metadata_and_previews: true)
        media_entry_with_image.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])

        media_entry_with_video = create(:media_entry_with_video_media_file,
                                        get_metadata_and_previews: true)
        media_entry_with_video.media_file.previews << \
          create(:preview, media_type: 'video')
        media_entry_with_video.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])

        media_entry_with_audio = create(:media_entry_with_audio_media_file,
                                        get_metadata_and_previews: true)
        media_entry_with_audio.media_file.previews << \
          create(:preview, media_type: 'audio')
        media_entry_with_audio.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])

        media_entry_with_document = create(:media_entry_with_document_media_file,
                                           get_metadata_and_previews: true)
        media_entry_with_document.media_file.previews << \
          create(:preview, media_type: 'image')
        media_entry_with_document.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])

        media_entry_with_other = create(:media_entry_with_other_media_file,
                                        get_metadata_and_previews: true)
        media_entry_with_other.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])

        # newest media_entry
        @media_entry_with_image = create(:media_entry_with_image_media_file,
                                         get_metadata_and_previews: true)
        @media_entry_with_image.meta_data << \
          create(:meta_datum_keywords,
                 meta_key: @context_key.meta_key,
                 keywords: [@keyword])
      end

      context 'for catalog context keys (1st level)' do
        it 'it counts entries having all different media_types' do
          visit explore_path
          label = @context_key.label || @context_key.meta_key.label
          within('.media-catalog', text: label) do
            expect(find('.ui-thumbnail-meta-extension').text).to be == '6'
          end
        end

        it 'shows the proper thumbnail (preview \'image\') for the newest entry' do
          visit catalog_key_thumb_path(@context_key, :medium, limit: 24)
          preview = \
            @media_entry_with_image.media_file.previews.find_by(thumbnail: :medium)
          expect(current_path).to be == preview_path(preview)
        end
      end

      context 'for catalog context key entries (2nd level)' do
        it 'it counts entries having all different media_types' do
          visit explore_catalog_category_path(@context_key)
          within('.media-catalog', text: @keyword.term) do
            expect(find('.ui-thumbnail-meta-extension').text).to be == '6'
          end
        end

        it 'shows the proper thumbnail (preview \'image\') for the newest entry' do
          visit catalog_key_item_thumb_path(@keyword, :medium)
          preview = \
            @media_entry_with_image.media_file.previews.find_by(thumbnail: :medium)
          expect(current_path).to be == preview_path(preview)
        end
      end
    end

    pending 'shows simple lists of Entries, Collections and FilterSets' \
      'with links to their indexes'

    specify 'Catalog section contains "show all" link' do
      visit explore_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Catalog'
      ) do
        expect(page).to have_link 'Alle anzeigen'
      end
    end

    specify 'Featured Set section contains "show all" link' do
      visit explore_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Featured Content'
      ) do
        expect(page).to have_link 'Alle anzeigen'
      end
    end

    specify 'Keywords section contains "show all" link' do
      visit explore_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Häufige Schlagworte'
      ) do
        expect(page).to have_link 'Alle anzeigen'
      end
    end
  end

  describe 'Action: catalog' do
    specify 'Catalog section does not contain "show all" link' do
      visit explore_catalog_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Browse the catalog'
      ) do
        expect(page).not_to have_link 'Alle anzeigen'
      end
    end
  end

  describe 'Action: featured_set' do
    specify 'Featured Set section does not contain "show all" link' do
      visit explore_featured_set_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Highlights from this Archive'
      ) do
        expect(page).not_to have_link 'Alle anzeigen'
      end
    end
  end

  describe 'Action: keywords' do
    specify 'Keywords section does not contain "show all" link' do
      visit explore_keywords_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Häufige Schlagworte'
      ) do
        expect(page).not_to have_link 'Alle anzeigen'
      end
    end
  end

  describe 'Explore content on login page' do

    it 'contains latest entries sorted by created_at DESC', browser: false do
      visit root_path
      expect(page.status_code).to eq 200
      within '.ui-resources-holder', text: I18n.t(:home_page_new_contents) do
        expect(
          all('.media-entry').map do |element|
            element.find('a')['href'].split('/').last
          end
        ).to be == \
          MediaEntry
          .viewable_by_public
          .reorder(created_at: :desc)
          .limit(12)
          .map(&:id)
      end
    end

    specify 'Catalog section contains "show all" link' do
      visit root_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Catalog'
      ) do
        expect(page).to have_link 'Alle anzeigen'
      end
    end

    specify 'Featured Set section contains "show all" link' do
      visit root_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Featured Content'
      ) do
        expect(page).to have_link 'Alle anzeigen'
      end
    end

    specify 'Latest Media Entries section does not contain "show all" link' do
      visit root_path

      within('.ui-resources-holder .ui-resources-header', text: 'Neue Inhalte') do
        expect(page).not_to have_link 'Alle anzeigen'
      end
    end

  end

end
