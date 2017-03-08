require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: User List Config (layout, order, …)' do

  background do
    # using personas data from normin
    @entry = MediaEntry.find('71196fee-abdb-41c1-98f7-48d62c9f0ae7')
    @set = Collection.find('d316b369-6d20-4eb8-b76a-c83f1a4c2682')
  end

  context 'list config follows user when browsing the archive' do

    example 'from dashboard section' do
      # confirm defaults:
      visit my_dashboard_section_path(:content_media_entries)
      sign_in_as('normin')
      expect_box_layout(:grid)

      # changing the layout changes the layout
      box_toggle_layout(:tiles)
      expect_box_layout(:tiles)

      # another dashboard section now has the same layout:
      visit my_dashboard_section_path(:content_collections)
      expect_box_layout(:tiles)

      # also on search results
      visit media_entries_path
      expect_box_layout(:tiles)

      # and vocabulary contents
      vocabulary_contents_path(:madek_core)
      expect_box_layout(:tiles)

      # a collection still has its "saved settings" applied:
      expect(@set.layout).to eq 'grid'
      visit collection_path(@set)
      expect_box_layout(@set.layout)
    end

    example 'from search results' do
      visit my_dashboard_section_path(:content_media_entries)
      sign_in_as('normin')

      # confirm defaults:
      visit media_entries_path
      expect_box_layout(:grid)

      # changing the layout changes the layout
      box_toggle_layout(:tiles)
      expect_box_layout(:tiles)

      # another dashboard section now has the same layout:
      visit my_dashboard_section_path(:content_media_entries)
      expect_box_layout(:tiles)

      # and vocabulary contents
      vocabulary_contents_path(:madek_core)
      expect_box_layout(:tiles)

      # a collection still has its "saved settings" applied:
      expect(@set.layout).to eq 'grid'
      visit collection_path(@set)
      expect_box_layout(@set.layout)
    end
  end

  example 'from set' do
    visit my_dashboard_section_path(:content_media_entries)
    sign_in_as('normin')

    # confirm defaults:
    expect(@set.layout).to eq 'grid'
    visit collection_path(@set)
    expect_box_layout(@set.layout)

    # changing the layout changes the layout
    box_toggle_layout(:tiles)
    expect_box_layout(:tiles)

    # also on search results
    visit media_entries_path
    expect_box_layout(:tiles)

    # another dashboard section now has the same layout:
    visit my_dashboard_section_path(:content_media_entries)
    expect_box_layout(:tiles)

    # and vocabulary contents
    vocabulary_contents_path(:madek_core)
    expect_box_layout(:tiles)
  end

  example 'not logged in, from search results' do
    visit media_entries_path
    expect_box_layout(:grid)
    box_toggle_layout(:tiles)

    visit collections_path
    expect_box_layout(:tiles)

    vocabulary_contents_path(:madek_core)
    expect_box_layout(:tiles)
  end

end

private

def expect_box_layout(mode)
  within_box do
    expect(find('.ui-resources')).to match_selector ".#{mode}"
  end
end

def box_toggle_layout(mode)
  within_box do
    find('.ui-toolbar-controls a[mode="' + mode.to_s + '"]').click
  end
end

def within_box(&block)
  within('.ui-polybox') { yield(block) }
end
