require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Filter Set ' do
  
  scenario 'Creating a FilterSet', browser: :firefox do

    @current_user = sign_in_as 'normin'

    visit '/search'

    submit_form

    click_on_text 'Datei'
    click_on_text 'Medientyp'
    click_on_text 'video'

    click_on_text 'Zusammenh'
    click_on_text 'Filterset erstellen'

    fill_in 'title', with: 'THE NEW TEST FILTERSET'
    click_on_text 'Set erstellen'
    wait_for_ajax

    # I am on the page of the new filter set 
    find('.title-l', text: 'THE NEW TEST FILTERSET')
    expect(current_path).to match /filter_sets/
    
    # video is selected
    click_on_text 'Filtern'
    click_on_text 'Datei'
    click_on_text 'Medientyp'
    find('ul.ui-side-filter-lvl3', text: 'video')

    # check that we are seeing indeed only videos
    all_entries_count = count_all_entries()
    videos_count = count_videos()
    expect(videos_count).to be >= 2
    expect(all_entries_count - videos_count).to be== 0
  end

  scenario 'Updating Filter Set', browser: :firefox do

    @current_user = sign_in_as 'normin'

    visit '/search'

    submit_form

    click_on_text 'Datei'
    click_on_text 'Medientyp'
    click_on_text 'video'

    click_on_text 'Zusammenh'
    click_on_text 'Filterset erstellen'

    fill_in 'title', with: 'THE NEW TEST FILTERSET'
    click_on_text 'Set erstellen'
    wait_for_ajax

    # I am on the page of the new filter set
    find('.title-l', text: 'THE NEW TEST FILTERSET')
    assert_partial_url_path /filter_sets/

    click_on_text 'Weitere Aktionen'
    click_on_text 'Filterset editieren'
    # clicking on video disables the video selection 
    click_on_text 'video'

    # start again since clicking on vide closes the filters (???)
    click_on_text 'Datei'
    click_on_text 'Medientyp'
    click_on_text 'audio'
    click_on_text 'Filterset speichern'
    wait_for_ajax

    # I am on the page of the new filter set 
    find('.title-l', text: 'THE NEW TEST FILTERSET')
    assert_partial_url_path /filter_sets/

    # audio is selected
    click_on_text 'Filtern'
    click_on_text 'Datei'
    click_on_text 'Medientyp'
    find('ul.ui-side-filter-lvl3', text: 'audio')

    # check that we are seeing indeed only audios 
    all_entries_count = count_all_entries()
    audios_count = count_audios()
    expect(audios_count).to be >= 1
    expect(all_entries_count - audios_count).to be== 0
  end

  def count_audios
    all("ul.ui-resources-page-items > li[data-media-type='audio']").count
  end

  def count_videos
    all("ul.ui-resources-page-items > li[data-media-type='video']").count
  end

  def count_all_entries
    all("ul.ui-resources-page-items > li[data-media-type]").count
  end

end
