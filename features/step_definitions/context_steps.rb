Then /^I see a preview list of contexts that are connected with media resources that I can access$/ do
  contexts_with_resources = @current_user.individual_contexts.reject do |context|
    not MediaResource.filter(@current_user, {:meta_context_ids => [context.id]}).exists?
  end
  all(".ui-contexts .ui-context").length > 0 if contexts_with_resources
  all(".ui-contexts .ui-context").each do |ui_context|
    contexts_with_resources.any? {|context| context.id == ui_context[:"data-id"]}
  end
end

Then /^for each context I see the label and description$/ do
  all(".ui-contexts .ui-context").each do |ui_context|
    context = MetaContext.find ui_context[:"data-id"]
    ui_context.should have_content context.label.to_s
    ui_context.should have_content context.description.to_s
  end
end

Then /^I see a list with all contexts that are connected with media resources that I can access$/ do
  contexts_with_resources = @current_user.individual_contexts.reject do |context|
    not MediaResource.filter(@current_user, {:meta_context_ids => [context.id]}).exists?
  end
  contexts_with_resources.each do |context|
    find(".ui-contexts .ui-context[data-id='#{context.id}']")
  end
end

When /^I open a specific context$/ do
  @context = @current_user.individual_contexts.find do |context|
    MediaResource.filter(@current_user, {:meta_context_ids => [context.id]}).exists?
  end
  visit context_path(@context)
end

Then /^I see the title of the context$/ do
  page.should have_content @context.label.to_s
end

Then /^I see the description of the context$/ do
  page.should have_content @context.description.to_s
end

Then /^I see all resources that are inheritancing that context and have any meta data for that context$/ do
  @media_resources = MediaResource.filter(@current_user, {:meta_context_ids => [@context.id]})
  expect( find("#ui-resources-list-container .ui-toolbar-header").text ).to include @media_resources.count.to_s
  all(".ui-resource", :visible => true).each do |resource_el|
    id = resource_el["data-id"]
    expect{@media_resources.include? MediaResource.find id}.to be_true
  end
end

Then /^I can go to the abstract of that context$/ do
  find(".ui-tabs-item a[href='#{context_abstract_path(@context)}']").click
  expect(current_path).to eq context_abstract_path @context
end

Then /^I can go to the vocabulary of that context$/ do
  find(".ui-tabs-item a[href='#{context_vocabulary_path(@context)}']").click
  expect(current_path).to eq context_vocabulary_path @context
end

When /^I use the highlight used vocabulary action$/ do
  find("#ui-highlight-used-terms").click
end

Then /^the unused values are faded out$/ do
  find(".highlight-used-terms")
  page.evaluate_script %Q{ Test.ContextVocabulary.all_unused_vocabulary_is_fade_out() }
end

Then /^I see all values that are at least used for one resource$/ do
  media_resources = MediaResource.filter(@current_user, {:meta_context_ids => [@context.id]})
  meta_data = media_resources.map { |resource| resource.meta_data.for_context @context }.flatten
  meta_data.reject! {|meta_datum| meta_datum.value.blank? }
  meta_data.map(&:value).flatten.map(&:to_s).each do |term|
    step %Q{I can see the text "#{term}"}
  end
end