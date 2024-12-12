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
      app_setting[:catalog_context_keys] = \
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
      within '.ui-resources-holder[id=catalog]' do
        within '.grid' do
          expect(all('h2').map(&:text)).to be == labels
        end
      end
    end

    describe 'dealing with empty catalog context keys (1st level)' do
      it 'doesn\'t show catalog section at all if the count of all is 0' do
        context_key = create(:context_key, meta_key: create(:meta_key_keywords))
        app_setting = AppSetting.first
        app_setting.update!(catalog_context_keys: [context_key.id],
                                       catalog_titles: { de: 'Catalog Title' })
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
        app_setting.update!(catalog_context_keys: [@context_key.id],
                                       catalog_titles: { de: 'Catalog Title' })

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
          within('[id=catalog]') do
            within('.ui-resource', text: label) do
              within('.media-catalog') do
                expect(find('.ui-thumbnail-meta-extension').text).to be == '6'
              end
            end
          end
        end

        it 'shows random thumbnail (preview \'image\') from the latest entries' do
          # NOTE: check 12 results + should have more than 1 uniq results
          thumbs = 12.times.map do
            visit catalog_key_thumb_path(@context_key, :medium, limit: 24)
            current_path
          end

          thumbs.each do |url|
            me = media_entry_from_preview_path_url(url)
            expect(me.meta_data.find_by!(meta_key: @context_key.meta_key)).to be
          end
          expect(thumbs.uniq.length).to be >= 2
        end
      end

      context 'for catalog context key entries (2nd level)' do
        it 'shows random thumbnail (preview \'image\') from the latest entries' do
          # NOTE: check 12 results + should have more than 1 uniq results
          thumbs = 12.times.map do
            visit catalog_key_item_thumb_path(:keywords, @keyword, :medium)
            current_path
          end

          thumbs.each do |url|
            me = media_entry_from_preview_path_url(url)
            expect(me.meta_data.find_by!(meta_key: @keyword.meta_key).keywords)
              .to include @keyword
          end
          expect(thumbs.uniq.length).to be >= 2
        end
      end
    end

    describe 'dealing with context keys of type MetaDatum::People' do
      before do
        @meta_key_people = \
          MetaKey.find_by_id('test:people') || create(:meta_key_people)
        @context_key = create(:context_key, meta_key: @meta_key_people)
        @person = create(:people_instgroup)
        app_setting = AppSetting.first
        app_setting.update!(
          catalog_context_keys: [@context_key.id],
          catalog_titles: { de: 'Catalog Title' }
        )
        media_entry_with_image = create(:media_entry_with_image_media_file,
                                        get_metadata_and_previews: true)
        media_entry_with_image.meta_data << \
          create(:meta_datum_people,
                 meta_key: @context_key.meta_key,
                 people: [@person])

        media_entry_with_image_2 = create(:media_entry_with_image_media_file,
                                          get_metadata_and_previews: true)
        media_entry_with_image_2.meta_data << \
          create(:meta_datum_people,
                 meta_key: @context_key.meta_key,
                 people: [@person])
      end

      context 'for catalog context key (1st level)' do
        it 'it counts entries' do
          visit explore_path
          label = @context_key.label || @context_key.meta_key.label
          within('[id=catalog]') do
            within('.ui-resource', text: label) do
              within('.media-catalog') do
                expect(find('.ui-thumbnail-meta-extension').text).to be == '2'
              end
            end
          end
        end

        it 'shows random thumbnail (preview \'image\') from the entry' do
          # NOTE: check 12 results + should have 2 uniq results
          thumbs = 12.times.map do
            visit catalog_key_thumb_path(@context_key, :medium, limit: 24)
            current_path
          end

          thumbs.each do |url|
            me = media_entry_from_preview_path_url(url)
            meta_key = me.meta_data.find_by!(
              meta_key: @person.meta_data.first.meta_key
            )
            expect(meta_key).to be
          end
          expect(thumbs.uniq.length).to be == 2
        end
      end

      context 'for catalog context key entries (2nd level)' do
        it 'shows random thumbnail (preview \'image\') from the entry' do
          # NOTE: check 12 results + should have 2 uniq results
          thumbs = 12.times.map do
            visit catalog_key_item_thumb_path(:people, @person, :medium)
            current_path
          end

          thumbs.each do |url|
            me = media_entry_from_preview_path_url(url)
            meta_key = me.meta_data.find_by!(
              meta_key: @person.meta_data.first.meta_key
            )
            expect(meta_key.people)
              .to include @person
          end
          expect(thumbs.uniq.length).to be == 2
        end
      end
    end

    specify 'Featured Set section contains "show all" link' do
      visit explore_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Featured Content'
      ) do
        expect(page).to have_link 'Weitere anzeigen'
      end
    end

    specify 'Featured Set can also contain media entries', browser: false do
      featured_set = Collection.find(AppSetting.first.featured_set_id)
      featured_set.media_entries << FactoryBot.create(:media_entry, get_metadata_and_previews: true)
      visit explore_path
      expect(page.status_code).to eq 200
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

    specify 'Featured Set section contains "show all" link' do
      visit root_path

      within(
        '.ui-resources-holder .ui-resources-header',
        text: 'Featured Content'
      ) do
        expect(page).to have_link 'Weitere anzeigen'
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

def media_entry_from_preview_path_url(url)
  preview = Preview.find(Rails.application.routes.recognize_path(url)[:id])
  MediaEntry.find_by_id(preview.media_file.media_entry_id)
end
