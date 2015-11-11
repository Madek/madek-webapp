require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'MediaResource' do

  scenario 'show relations of an entry', browser: :firefox do

    # I am Normin
    @current_user = sign_in_as 'normin'

    # I'll check the Entry 'Ausstellung Photo 4'
    id = '81880474-ce44-4006-861c-dd7743b94005'
    relations_path = relations_media_entry_path id

    # I visit it's "Relations" Tab
    visit relations_path

    # I can see containers for Parent-, Sibling- and Child-MediaSets
    parents = '#set-relations-parents.ui-resources-holder'
    siblings = '#set-relations-siblings.ui-resources-holder'

    # The counters should be correct
    expect(find(parents).find('.ui-counter').text).to eq "(1)"
    expect(find(siblings).find('.ui-counter').text).to eq "(3)"

    # All 3 sections have working sub views
    all_subviews_working([parents, siblings])

  end

  scenario 'show relations of a set', browser: :firefox do

    # I am Normin
    @current_user = sign_in_as 'normin'

    # I'll check the Set 'Ausstellungen'
    id = '351ffad4-bddc-48b7-981b-50a56a7998ea'
    relations_path = relations_media_set_path id

    if MediaResource.find_by(id: id).is_a? MediaSet

    else
      relations_path = relations_media_entry_path id
    end

    # I visit it's "Relations" Tab
    visit relations_path

    # I can see containers for Parent-, Sibling- and Child-MediaSets
    parents = '#set-relations-parents.ui-resources-holder'
    siblings = '#set-relations-siblings.ui-resources-holder'
    children = '#set-relations-children.ui-resources-holder'

    # The counters should be correct
    expect(find(parents).find('.ui-counter').text).to eq "(4)"
    expect(find(siblings).find('.ui-counter').text).to eq "(1)"
    expect(find(children).find('.ui-counter').text).to eq "(3)"

    # All 3 sections have working sub views

    all_subviews_working([parents, siblings, children])

  end

  def all_subviews_working(sections)
    sections.each do |section_id|
      # - should have a 'Show All' link in header

      show_all_link = find(section_id)
        .find(".ui-resources-header a", text: "Alle anzeigen")

      # - which can be visited
      unhover
      hide_clipboard
      show_all_link.click

      # - sub-view has link back to main view
      back_link = find(
        '.ui-resources-header a', text: "Alle Zusammenhänge anzeigen")
      unhover
      hide_clipboard
      back_link.click
    end
  end

end
