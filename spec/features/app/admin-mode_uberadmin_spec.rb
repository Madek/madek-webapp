require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'App: Admin-Mode (Uberadmin/Superadmin)' do

  background do
    # using personas data from normin
    @entry = MediaEntry.find('71196fee-abdb-41c1-98f7-48d62c9f0ae7')
    @set = Collection.find('d316b369-6d20-4eb8-b76a-c83f1a4c2682')
  end

  example 'admin mode scenario' do
    sign_in_as('adam')

    # check correct permissions WITHOUT admin-mode:
    expect_vocabs_visible(
      ['Madek Core', 'ZHdK', 'Werk', 'Nutzung', 'Credits',
       'Medium', 'Core', 'Set'])

    visit media_entry_path(@entry)
    expect(page).to have_content 'Error 403'

    visit collection_path(@set)
    expect(page).to have_content 'Error 403'

    # enter uberadmin mode
    open_user_menu
    user_menu.click_on(I18n.t(:user_menu_admin_mode_toogle_on))
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus aktiviert!'

    # check correct permissions:
    expect_vocabs_visible(
      ['Madek Core', 'Computergestützte Architekturgeschichte',
       'Forschung ZHdK', 'Landschaftsvisualisierung', 'Performance-Artefakte',
       'Supply Lines', 'Säulenordnungen', 'Umbau Toni-Areal',
       'Lehrmittel Fotografie', 'Produktion Zett', 'ZHdK', 'Werk', 'Nutzung',
       'Credits', 'Medium', 'Core', 'Set'])

    visit media_entry_path(@entry)
    expect(page).to have_content @entry.title

    visit collection_path(@set)
    expect(page).to have_content @set.title

    # leave uberadmin mode
    open_user_menu
    user_menu.click_on(I18n.t(:user_menu_admin_mode_toogle_off))
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus deaktiviert!'

    visit media_entry_path(@entry)
    expect(page).to have_content 'Error 403'
  end

end

# helpers

def user_menu
  page.find('.ui-header .ui-header-user')
end

def user_menu_toggle
  user_menu.find('.dropdown-toggle')
end

def open_user_menu
  user_menu_toggle.click
end

#

def expect_vocabs_visible(list)
  visit vocabularies_path
  expect(page.all('.app-body .ui-container.bright .title-l').map(&:text))
    .to match_array(list)
end
