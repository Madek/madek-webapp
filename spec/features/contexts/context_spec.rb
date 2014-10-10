require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Context" do

  background do
    @current_user = sign_in_as "normin"
  end

  scenario "See a list of contexts" do

    visit "/my"

    # I see a preview list of contexts that are connected with media resources that I can access
    contexts_with_resources = @current_user.individual_contexts.reject do |context|
      not MediaResource.filter(@current_user, {:context_ids => [context.id]}).exists?
    end
    all(".ui-contexts .ui-context").length > 0 if contexts_with_resources
    all(".ui-contexts .ui-context").each do |ui_context|
      expect(contexts_with_resources.any? {|context| context.id == ui_context[:"data-name"]}).to be true
    end

    # for each context I see the label and description and the link to that context
    check_label_description_link_of_contexts

    visit my_contexts_path

    # I see a list with all contexts that are connected with media resources that I can access
    contexts_with_resources = @current_user.individual_contexts.reject do |context|
      not MediaResource.filter(@current_user, {:context_ids => [context.id]}).exists?
    end
    contexts_with_resources.each do |context|
      find(".ui-contexts .ui-context[data-name='#{context.id}']")
    end

    # for each context I see the label and description and the link to that context
    check_label_description_link_of_contexts

  end

  scenario "Open a specific context", browser: :headless do

    open_specific_context

    expect(page).to have_content @context.label.to_s
    expect(page).to have_content @context.description.to_s

    click_on_text "Inhalte"

    # I see all resources that are using that context
    assert_resources_with_context

  end

  scenario "Highlight used vocabulary", browser: :headless do

    open_specific_context

    # I use the highlight used vocabulary action
    find('[data-filter-mode="used"]').click

    # the unused values are faded out
    find('[data-filter-mode="used"]')
    page.evaluate_script %Q{ Test.ContextVocabulary.all_unused_vocabulary_is_fade_out() }

  end

  scenario "Interact with the abstract slider of a context", browser: :headless do

    open_specific_context

    # I see all values that are at least used for one resource
    assert_all_values_used_for_at_least_one_resource

    open_specific_context

    # I use the filter used vocabulary action
    find('[data-filter-mode="frequent"]').click

    # I see all values that are at least used for one resource
    assert_all_values_used_for_at_least_one_resource

  end

  def check_label_description_link_of_contexts
    all(".ui-contexts .ui-context").each do |ui_context|
      context = Context.find ui_context[:"data-name"]
      ui_context.should have_content context.label.to_s
      ui_context.should have_content context.description.to_s
      ui_context.find("a[href='#{context_path(context)}']").should have_content context.label.to_s
    end
  end

  def open_specific_context
    @context = @current_user.individual_contexts.find do |context|
      MediaResource.filter(@current_user, {:context_ids => [context.id]}).exists?
    end
    visit context_path(@context)
    expect(page).to have_selector ".view-meta-context[data-id='#{@context.label}']"
  end

  def assert_resources_with_context
    @media_resources = MediaResource.filter(@current_user, {:context_ids => [@context.id]})
    expect( find("#ui-resources-list-container .ui-resources-page-counter").text ).to include @media_resources.count.to_s
    all(".ui-resource", :visible => true).each do |resource_el|
      id = resource_el["data-id"]
      expect(@media_resources.include? MediaResource.find id).to be true
    end
  end

  def assert_all_values_used_for_at_least_one_resource
    media_resources = MediaResource.filter(@current_user, {:context_ids => [@context.id]})
    meta_data = media_resources.map { |resource| resource.meta_data.for_context @context }.flatten
    meta_data.reject! {|meta_datum| meta_datum.value.blank? }
    meta_data.map(&:value).flatten.map(&:to_s).each do |term|
      expect(page).to have_content term
    end
  end

end
