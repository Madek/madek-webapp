require 'spec_helper'
require 'spec_helper_feature'
require_relative '../shared/basic_data_helper_spec'

include BasicDataHelper

feature 'Collection manual sorting' do
  background do
    prepare_user
  end

  context 'when user is not logged in' do
    scenario 'Arrows are not visible' do
      collection = create_collection('test collection')
      3.times do |i|
        collection.media_entries << create_media_entry("Entry #{i}")
      end

      visit_collection(collection)

      3.times do |i|
        el = hover_on_entry("Entry #{i}")
        expect(el).to have_no_css(direction_to_icon_map(:beginning))
        expect(el).to have_no_css(direction_to_icon_map(:left))
        expect(el).to have_no_css(direction_to_icon_map(:right))
        expect(el).to have_no_css(direction_to_icon_map(:end))
      end
    end
  end

  context 'when user is logged in' do
    background { login }

    scenario 'Sorting media entries' do
      collection = create_collection('my set')
      3.times do |i|
        collection.media_entries << create_media_entry("Entry #{i}")
      end

      visit_collection(collection)

      expect(media_entry_titles).to eq(['Entry 2', 'Entry 1', 'Entry 0'])
      move_entry('Entry 2', to: :beginning)
      expect(media_entry_titles).to eq(['Entry 2', 'Entry 1', 'Entry 0'])
      move_entry('Entry 1', to: :beginning)
      expect(media_entry_titles).to eq(['Entry 1', 'Entry 2', 'Entry 0'])
      move_entry('Entry 0', to: :beginning)
      expect(media_entry_titles).to eq(['Entry 0', 'Entry 1', 'Entry 2'])

      move_entry('Entry 0', to: :left)
      expect(media_entry_titles).to eq(['Entry 0', 'Entry 1', 'Entry 2'])
      move_entry('Entry 1', to: :left)
      expect(media_entry_titles).to eq(['Entry 1', 'Entry 0', 'Entry 2'])
      move_entry('Entry 2', to: :left)
      expect(media_entry_titles).to eq(['Entry 1', 'Entry 2', 'Entry 0'])

      move_entry('Entry 0', to: :right)
      expect(media_entry_titles).to eq(['Entry 1', 'Entry 2', 'Entry 0'])
      move_entry('Entry 2', to: :right)
      expect(media_entry_titles).to eq(['Entry 1', 'Entry 0', 'Entry 2'])
      move_entry('Entry 1', to: :right)
      expect(media_entry_titles).to eq(['Entry 0', 'Entry 1', 'Entry 2'])

      move_entry('Entry 2', to: :end)
      expect(media_entry_titles).to eq(['Entry 0', 'Entry 1', 'Entry 2'])
      move_entry('Entry 1', to: :end)
      expect(media_entry_titles).to eq(['Entry 0', 'Entry 2', 'Entry 1'])
      move_entry('Entry 0', to: :end)
      expect(media_entry_titles).to eq(['Entry 2', 'Entry 1', 'Entry 0'])
    end

    scenario 'Sorting the same media entries in two sets' do
      collection_1 = create_collection('Collection 1')
      collection_2 = create_collection('Collection 2')
      media_entry_a = create_media_entry('Entry A')
      media_entry_b = create_media_entry('Entry B')
      media_entry_c = create_media_entry('Entry C')

      collection_1.media_entries << [
        media_entry_a, media_entry_b, media_entry_c
      ]

      collection_2.media_entries << [
        media_entry_c, media_entry_a, media_entry_b
      ]

      visit_collection(collection_1)
      expect(media_entry_titles).to eq(['Entry C', 'Entry B', 'Entry A'])
      move_entry('Entry B', to: :end)
      expect(media_entry_titles).to eq(['Entry C', 'Entry A', 'Entry B'])
      reload_page
      expect(media_entry_titles).to eq(['Entry C', 'Entry A', 'Entry B'])

      visit_collection(collection_2)
      expect(media_entry_titles).to eq(['Entry C', 'Entry B', 'Entry A'])
      move_entry('Entry A', to: :beginning)
      expect(media_entry_titles).to eq(['Entry A', 'Entry C', 'Entry B'])
      reload_page
      expect(media_entry_titles).to eq(['Entry A', 'Entry C', 'Entry B'])

      visit_collection(collection_1, order: 'manual ASC')
      expect(media_entry_titles).to eq(['Entry C', 'Entry A', 'Entry B'])
      move_entry('Entry B', to: :end)
      expect(media_entry_titles).to eq(['Entry C', 'Entry A', 'Entry B'])
      visit_collection(collection_2, order: 'manual ASC')
      expect(media_entry_titles).to eq(['Entry A', 'Entry C', 'Entry B'])
    end
  end
end

def scroll_to_bottom
  page.evaluate_script('window.scrollTo(0, document.body.scrollHeight)')
end

def visit_collection(collection, order: nil)
  params = {}
  params[:list] = { order: order } if order
  visit collection_path(collection, params)
  scroll_to_bottom
end

def reload_page
  page.evaluate_script('window.location.reload()')
  scroll_to_bottom
end

def media_entry_titles
  within('.ui-polybox') do
    all('.ui-resource .ui-thumbnail-meta-title').map(&:text)
  end
end

def hover_on_entry(title)
  el = find('.ui-polybox .ui-resource', text: title)
  el.hover
  el
end

def direction_to_icon_map(direction)
  {
    beginning: '.icon-move-left-first',
    left: '.icon-move-left',
    right: '.icon-move-right',
    end: '.icon-move-right-last'
  }.fetch(direction)
end

def move_entry(title, to:)
  el = hover_on_entry(title)
  el.find(direction_to_icon_map(to)).click
end
