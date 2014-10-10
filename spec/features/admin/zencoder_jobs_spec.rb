require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Zencoder Jobs' do
  background { sign_in_as 'adam' }

  scenario 'Filtering by failed state' do
    visit '/app_admin/zencoder_jobs'

    check 'failed'
    click_button 'Filter'

    expect(all('table tbody tr', text: 'failed').size).
      to eq(all('table tbody tr').size)
  end
end
