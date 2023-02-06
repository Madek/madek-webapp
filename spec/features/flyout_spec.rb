require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Collection: Index' do

  describe 'Client: Flyouts' do
    scenario 'Flyouts shows parent- and child-relation' do
      login
      # need to put the mouse on top of page so it not hovers to early…
      page.first('#app header').hover

      open_collections

      thumbnail1 = find_thumbnail_by_title('Collection 1')
      check_parent_link_count(thumbnail1, 1)
      check_parent_contains_link(thumbnail1, @collection2)
      check_child_link_count(thumbnail1, 1)
      check_child_contains_link(thumbnail1, @media_entry)

      thumbnail2 = find_thumbnail_by_title('Collection 2')
      check_parent_link_count(thumbnail2, 0)
      check_child_link_count(thumbnail2, 1)
      check_child_contains_link(thumbnail2, @collection1)
    end
  end

  private

  def get_flyout_from_thumbnail(thumbnail, parent_or_child)
    up_down = case parent_or_child
              when :parent then 'up'
              when :child then 'down'
              else raise 'wrong argument'
    end

    area = thumbnail
      .find('.ui-thumbnail-level-' + up_down + '-items', visible: false)

    # hover thumbnail to open the flyout
    if (area.all('.ui-preloader', visible: false)[0])
      # 1st time hover, triggering async loading of content
      thumbnail.hover
      # wait until the preloader is gone (i.e. the content has been loaded)
      expect(area).not_to have_css('.ui-preloader', visible: false)
    else
      thumbnail.hover
    end

    # now hover over flyout itself for good measure, and then return the element
    area.hover
    expect(area.visible?).to eq true
    area
  end

  def check_parent_or_child_link_count(thumbnail, count, parent_or_child)
    area = get_flyout_from_thumbnail(thumbnail, parent_or_child)
    count_text = area.all('.ui-thumbnail-level-notes')[1].text

    text =
      if parent_or_child == :parent
        'Sets'
      elsif parent_or_child == :child
        'Inhalte'
      else
        raise 'wrong argument'
      end
    expect(count_text).to eq(count.to_s + ' ' + text)
  end

  def check_parent_link_count(thumbnail, count)
    check_parent_or_child_link_count(thumbnail, count, :parent)
  end

  def check_child_link_count(thumbnail, count)
    check_parent_or_child_link_count(thumbnail, count, :child)
  end

  def check_parent_contains_link(thumbnail, resource)
    check_parent_or_child_contains_link(thumbnail, resource, :parent)
  end

  def check_child_contains_link(thumbnail, resource)
    check_parent_or_child_contains_link(thumbnail, resource, :child)
  end

  def check_parent_or_child_contains_link(thumbnail, resource, parent_or_child)
    area = get_flyout_from_thumbnail(thumbnail, parent_or_child)
    class_name = resource.class.name
    expected_link =
      if class_name == 'Collection'
        collection_path(resource)
      elsif class_name == 'MediaEntry'
        media_entry_path(resource)
      else
        raise 'Resource class not expected ' + class_name
      end
    contains = false
    area.all('a.ui-level-image-wrapper').each do |link|
      if URI.parse(link[:href]).path == expected_link
        contains = true
      end
    end
    expect(contains).to eq(true)
  end

  def find_thumbnail_by_title(title)
    find('.ui-resources').all('.ui-resource').each do |resource|
      meta_titles = resource.all('.ui-thumbnail-meta-title', text: title)
      unless meta_titles.empty?
        return resource
      end
    end
    nil
  end

  def open_collections
    visit my_dashboard_section_path(:content_collections)
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

  def prepare_collection(title)
    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    collection
  end

  def prepare_user
    @login = 'user'
    @password = '1234'
    @user = FactoryBot.create(:user, login: @login, password: @password)
  end

  def prepare_media_entry
    @media_entry = FactoryBot.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)

    @media_file = FactoryBot.create(
      :media_file_for_image,
      media_entry: @media_entry)

    FactoryBot.create(
      :meta_datum_text,
      created_by: @user,
      meta_key: meta_key_title,
      media_entry: @media_entry,
      value: 'Medien Eintrag 1')
  end

  def prepare_collections
    @collection1 = prepare_collection('Collection 1')
    @collection2 = prepare_collection('Collection 2')
    @collection1.media_entries << @media_entry
    expect do
      @collection1.parent_collections << @collection1
    end.to raise_error(/function collection_may_not_be_its_own_parent/i)
    @collection1.parent_collections << @collection2
  end

  def prepare_data
    prepare_user
    prepare_media_entry
    prepare_collections
  end

  def login
    prepare_data
    sign_in_as @login, @password
  end

end
