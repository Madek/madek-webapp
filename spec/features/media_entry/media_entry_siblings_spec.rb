require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Media Entry Siblings' do
  context 'when user is logged in' do
    given(:user) { create(:user) }
    given(:media_entry) { create_media_entry(responsible_user: user) }

    background { sign_in_as(user) }

    context 'when media entry has siblings' do
      given(:media_entry_with_user_permission) { create_media_entry }
      given(:media_entry_with_group_permission) { create_media_entry }
      given(:media_entry_with_public_permission) do
        create_media_entry(get_metadata_and_previews: true)
      end
      given(:inaccessible_media_entry) { create_media_entry }
      given(:collection) { create_collection(responsible_user: user) }
      given(:collection_with_user_permission) { create_collection }
      given(:collection_with_group_permission) { create_collection }
      given(:collection_without_media_entries) do
        create_collection(title: 'Collection without media entries', responsible_user: user)
      end
      given(:collection_with_only_one_media_entry) do
        create_collection(title: 'Collection with only one media entry', responsible_user: user)
      end
      given(:inaccessible_collection) { create_collection }

      background do
        grant_user_permission_for(media_entry_with_user_permission, user)
        grant_group_permission_for(media_entry_with_group_permission, user)
        grant_user_permission_for(collection_with_user_permission, user)
        grant_user_permission_for(collection_with_group_permission, user)

        collection.media_entries << [
          media_entry,
          media_entry_with_user_permission,
          media_entry_with_group_permission,
          media_entry_with_public_permission,
          create(:media_entry_with_image_media_file)
        ]
        collection_with_user_permission.media_entries << [
          media_entry,
          media_entry_with_group_permission,
          create(:media_entry_with_image_media_file)
        ]
        collection_with_group_permission.media_entries << [
          media_entry,
          media_entry_with_user_permission
        ]
        collection_with_only_one_media_entry.media_entries << media_entry
        inaccessible_collection.media_entries << [
          media_entry,
          media_entry_with_group_permission,
          create(:media_entry_with_image_media_file)
        ]
      end

      scenario 'Show sibling media entries from two sets viewable by user' do
        visit media_entry_path(media_entry)

        within_collection(collection) do
          expect_no_media_entry(media_entry)
          expect_no_media_entry(inaccessible_media_entry)
          expect_media_entry(media_entry_with_user_permission)
          expect_media_entry(media_entry_with_group_permission)
        end

        within_collection(collection_with_user_permission) do
          expect_no_media_entry(media_entry)
          expect_no_media_entry(inaccessible_media_entry)
          expect_media_entry(media_entry_with_group_permission)
        end

        within_collection(collection_with_group_permission) do
          expect_no_media_entry(media_entry)
          expect_no_media_entry(inaccessible_media_entry)
          expect_media_entry(media_entry_with_user_permission)
        end

        expect_no_collection(collection_without_media_entries)
        expect_no_collection(collection_with_only_one_media_entry)
        expect_no_collection(inaccessible_collection)
      end
    end

    context 'when media entry do not have any siblings' do
      scenario 'Show no content fallback' do
        visit media_entry_path(media_entry)

        within_container do
          expect(page).to have_content(I18n.t(:no_content_fallback))
          expect(page).to have_no_selector('.ui-sibling-entries')
        end
      end
    end
  end

  context 'when user is not logged in' do
    given(:media_entry) { create_media_entry(get_metadata_and_previews: true) }
    given(:non_public_media_entry) { create_media_entry }
    given(:public_media_entry) { create_media_entry(get_metadata_and_previews: true) }
    given(:public_collection) { create_collection(get_metadata_and_previews: true) }
    given(:non_public_collection) { create_collection }

    background do
      public_collection.media_entries << [
        media_entry,
        non_public_media_entry,
        public_media_entry
      ]

      non_public_collection.media_entries << [
        media_entry,
        non_public_media_entry,
        public_media_entry
      ]
    end

    scenario 'Show public sibling media entries from public sets' do
      visit media_entry_path(media_entry)

      within_collection(public_collection) do
        expect_no_media_entry(media_entry)
        expect_no_media_entry(non_public_media_entry)
        expect_media_entry(public_media_entry)
      end

      expect_no_collection(non_public_collection)
    end
  end
end

def create_media_entry(**opts)
  media_entry = create(:media_entry_with_title, opts)
  create(:media_file_for_image, media_entry: media_entry)
  media_entry
end

def create_collection(**opts)
  create(:collection_with_title, opts)
end

def permission_resource_key(resource)
  resource.class.name.underscore.to_s
end

def permission_factory(resource, type)
  "#{permission_resource_key(resource)}_#{type}_permission"
end

def grant_user_permission_for(resource, user)
  create(permission_factory(resource, :user),
         get_metadata_and_previews: true,
         user: user,
         permission_resource_key(resource) => resource)
end

def grant_group_permission_for(resource, user)
  group = create(:group)
  group.users << user
  create(permission_factory(resource, :group),
         get_metadata_and_previews: true,
         group: group,
         permission_resource_key(resource) => resource)
end

def within_container
  within(find('.ui-container', text: I18n.t(:media_entry_siblings_section_title))) { yield }
end

def within_collection(collection)
  set_container = find('.ui-sibling-entries',
                       text: "#{I18n.t(:media_entry_siblings_parent_set)} #{collection.title}")

  within_container do
    within(set_container) { yield }
  end
end

def expect_media_entry(media_entry)
  expect(page).to have_link(nil, href: media_entry_path(media_entry))
end

def expect_no_media_entry(media_entry)
  expect(page).to have_no_link(nil, href: media_entry_path(media_entry))
end

def expect_no_collection(collection)
  within_container do
    expect(page).to have_no_selector(
      '.ui-sibling-entries',
      text: "#{I18n.t(:media_entry_siblings_parent_set)} #{collection.title}")
  end
end
