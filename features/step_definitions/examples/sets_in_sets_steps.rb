# coding: UTF-8

Given /^a context$/ do
  name = "Landschaftsvisualisierung"
  @context = MetaContext.send(name)
  @context.should_not be_nil
  @context.name.should == name
  @context.to_s.should_not be_empty
  @context.to_s.should == name
end

When /^I look at a page describing this context$/ do
  visit meta_context_path(@context)
  page.should have_content(@context.to_s)
end

Then /^I see all the keys that can be used in this context$/ do
  find_link("Vokabular").click
  @context.meta_keys.for_meta_terms.each do |meta_key|
    definition = meta_key.meta_key_definitions.for_context(@context)
    label = definition.meta_field.label
    page.should have_content(label)
  end
end

Then /^I see all the values those keys can have$/ do
  @context.meta_keys.for_meta_terms.each do |meta_key|
    meta_key.meta_terms.each do |meta_term|
      page.should have_content(meta_term.to_s)
    end
  end
end

Then /^I see an abstract of the most assigned values from media entries using this context$/ do
  find_link("Auszug").click
  find("#slider")
end
