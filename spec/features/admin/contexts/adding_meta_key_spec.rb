require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Contexts', browser: :firefox do

  scenario 'Adding a meta key to a context' do

    sign_in_as 'adam'

    visit '/app_admin/contexts'
    find('a', text: 'Edit', match: :first).click
    find('a', text: 'Add Meta Key Definition', match: :first).click

    expect(page).to have_css('form#new_meta_key_definition')
    expect(page).not_to have_content 'Length min'
    expect(page).not_to have_content 'Length max'
    expect(page).not_to have_content 'Input type'

    select 'version', from: 'meta_key_definition[meta_key_id]'
    select 'Games', from: 'meta_key_definition[context_id]'
    fill_in 'meta_key_definition[label]', with: 'LABEL'
    fill_in 'meta_key_definition[hint]', with: 'HINT'
    fill_in 'meta_key_definition[description]', with: 'DESCRIPTION'
    find("#new_meta_key_definition input[type='submit']").click

    expect(page).to have_css('.alert-success')
    expect(current_url).to match "/app_admin/contexts/copyright/meta_key_definitions/[^/]+/edit"
    expect(page).to have_content 'Length min'
    expect(page).to have_content 'Length max'
    expect(page).to have_content 'Input type'

    find("input[type='submit']").click

    expect(page).to have_css('.alert-success')

    row = find('table tbody tr', match: :first)
    %w{version LABEL HINT DESCRIPTION}.each_with_index do |value, index|
      expect(row.all('td')[index]).to have_content(value)
    end
  end

end
