require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Statistics' do
  background { sign_in_as 'Adam' }

  scenario 'Visiting the page with statistics' do
    visit '/app_admin'
    expect_menu_item 'Info + Statistics'
    click_link 'Info + Statistics'
    expect(page).to have_content 'Info and Statistics'
  end

  scenario 'Listing amounts of all categories' do
    visit '/app_admin'
    click_link 'Info + Statistics'
    expect_statistics_numbers
  end

  def expect_statistics_numbers
    categories = %w{Users People Groups Keywords Media Sets FilterSets}
    categories += ['MediaFiles without MediaEntry', 'videos with incomplete previews']
    cells = all('table tbody td').to_a
    categories.each do |category|
      cells.delete_if { |cell| cell.text =~ /\d+\s+#{category}/ }
    end
    expect(cells).to be_empty
  end

  def expect_menu_item(anchor_text)
    within find('.navbar-nav', match: :first) do
      expect(page).to have_css('a', text: 'Info + Statistics')
    end
  end
end
