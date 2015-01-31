require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Inheritance of contexts" do

  background do
    @current_user = sign_in_as "adam"
  end

  scenario "Inherit contexts from another set", browser: :firefox do

    # I put a set A that has media entries in set B that has any context
    @media_set_a = MediaSet.find "434c473e-c685-4ea8-83f1-ceebff16c843"
    @media_set_a.individual_contexts.count.should be== 0
    @media_set_a.child_media_resources.media_entries.count.should be> 0

    @media_set_b = MediaSet.find "b23c6f19-4fdd-4e7d-b48e-697953fe5f12"
    @media_set_b.individual_contexts.count.should be> 0

    put_set_into_another_set @media_set_a, @media_set_b
    ######################################################################

    click_on_text "Vokabular"

    # all the contexts of the set B are listed for set A
    find("a[href='#{context_media_set_path(@media_set_a, @media_set_a.individual_contexts.first)}']").click
    find("p", text: 'Vokabular verfügbar')
    @media_set_b.individual_contexts.each do |context|
      page.should have_content context.label.to_s
      find("a[href='#{context_path context}']")
    end
    ######################################################################

  end

  scenario "Remove contexts from a set while disconnecting from inheriting set", browser: :firefox do

    # I put a set A that has media entries in set B that has any context
    @media_set_a = MediaSet.find "434c473e-c685-4ea8-83f1-ceebff16c843"
    @media_set_a.individual_contexts.count.should be== 0
    @media_set_a.child_media_resources.media_entries.count.should be> 0

    @media_set_b = MediaSet.find "b23c6f19-4fdd-4e7d-b48e-697953fe5f12"
    @media_set_b.individual_contexts.count.should be> 0

    put_set_into_another_set @media_set_a, @media_set_b
    ######################################################################

    # I remove a set A from a set B from which set A is inheriting a context
    @individual_context = @media_set_b.individual_contexts.first
    visit media_set_path(@media_set_a)
    open_organize_dialog
    expect(page).to have_selector "#parent_resource_#{@media_set_b.id}"
    find("#parent_resource_#{@media_set_b.id}").click
    submit_form
    assert_modal_not_visible
    ######################################################################

    # this context is removed from set A
    expect(@media_set_a.individual_contexts.include?(@individual_context)).to be false
    ######################################################################

    # all media entries contained in set A doesnt have that context anymore
    @media_set_a.child_media_resources.media_entries.accessible_by_user(@current_user,:view).each do |media_entry|
      visit contexts_media_entry_path media_entry
      @media_set_a.individual_contexts.each do |context|
        page.should_not have_content context.label
      end
    end
    ######################################################################

  end

  scenario "Disconnect contexts from a set", browser: :headless do

    # I edit the contexts of a set that has contexts
    @media_set = @current_user.media_sets.detect{|ms| ms.individual_contexts.count > 0}
    @individual_contexts = @media_set.individual_contexts
    visit context_media_set_path(@media_set, @media_set.individual_and_inheritable_contexts.first)
    ######################################################################

    # I disconnect any contexts from that set
    @individual_contexts.each do |context|
      find("a, button", text: "Entfernen").click
    end
    ######################################################################

    assert_modal_visible "Zuweisung entfernen"
    click_primary_action_of_modal

    # those contexts are no longer connected to that set
    @individual_contexts.each do |context|
      expect(@media_set.reload.individual_contexts.include? context).to be false
    end
    ######################################################################

    # all media entries contained in that set do not have the disconnected contexts any more
    @media_set.child_media_resources.media_entries.each do |media_entry|
      @individual_contexts.each do |context|
        expect(media_entry.individual_contexts.include? context).to be false
      end
    end
    ######################################################################

  end

  def open_organize_dialog
    expect(page).to have_selector '.app[data-id]'
    expect(page).to have_selector 'a[data-organize-arcs]'
    find('a[data-organize-arcs]', match: :first).click
    assert_modal_visible
  end

  def put_set_into_another_set set1, set2
    visit media_set_path(set1)

    open_organize_dialog

    find("[name='search_or_create_set']").set set2.title
    expect(page).to have_selector "#parent_resource_#{set2.id}"
    find("#parent_resource_#{set2.id}").click

    submit_form
    assert_modal_not_visible
  end

end
