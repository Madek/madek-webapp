When /^I look at one of these pages then I can see the action bar:$/ do |table|
  table.hashes.each do |row|
    step 'I go to %s' % row[:page_type]
    wait_until { find("#bar") }
  end
end

When /^I see the action bar$/ do
  step 'I go to public content'
end

Then /^I can choose between showing (.*)$/ do |type|
  wait_until { find("#bar") }
  case type
    when "only sets"
      find("#bar .selection .types .media_sets").click
      wait_until { find(".item_box") }
      all(".item_box:not(.set)").size.should == 0
    when "only media entries"
      find("#bar .selection .types .media_entries").click
      wait_until { find(".item_box") }
      all(".item_box.set").size.should == 0
    when "media entries and sets"
      find("#bar .selection .types .all").click
      wait_until { find(".item_box") }
      all(".item_box.set").size.should_not == 0
      all(".item_box:not(.set)").size.should_not == 0
  end
end

Then /^I can sort by (.*)$/ do |sort_by|
  wait_until { find("#bar") }
  page.execute_script("$('#bar .sort a').show()")
  s = case sort_by
    when "created at"
      ".created_at"
    when "updated at"
      ".updated_at"
    when "title" 
      ".title"
    else
      ".#{sort_by}"
  end
  find("#bar .sort #{s}").click
  underscored_sort_by = sort_by.gsub(/\s/, '_')
  wait_until { find("#bar .sort .#{underscored_sort_by}.active") }
end  
  
Then /^the results are sorted by (.*)$/ do |sort_by|
  underscored_sort_by = sort_by.gsub(/\s/, '_')
  wait_until { find(".results .item_box[data-id]") }
  dom_ids = all(".results .item_box[data-id]").map {|x| x[:"data-id"].to_i}
  
  env = Rack::MockRequest.env_for(current_url)
  request = Rack::Request.new(env)
  @filter = request.params.select do |k,v| 
    MediaResourceModules::Filter::KEYS.include?(k.to_sym) 
  end.delete_if {|k,v| v.blank?}.deep_symbolize_keys
    
  model_sorted_ids = MediaResource.filter(@current_user, @filter).
                      ordered_by(underscored_sort_by).
                      paginate(:page => 1, :per_page => PER_PAGE.first).
                      map(&:id)
  model_sorted_ids.should == dom_ids
end

When /^I can switch the layout of the results to the (.*) view$/ do |layout|
  wait_until { find("#bar") }
  find("section.media_resources.index #bar .layout").find(:xpath, "a[@data-type = '#{layout}']").click
  wait_until { find("#bar") }
  find("section.media_resources.index.#{layout} #bar .layout").find(:xpath, "a[@data-type = '#{layout}']")
end

When /^I change any of the settings in the bar then i am forwarded to a different page url$/ do
  step 'I see the action bar'
  last_url = current_url
  step 'I can choose between showing only sets'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can choose between showing only media entries'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can choose between showing media entries and sets'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by created at'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by updated at'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by title'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by author'
  last_url.should_not be current_url
  last_url = current_url
end

Then /^the counter is formatted as "([^"]*)"$/ do |string|
  re = Regexp.new(string.gsub(/[N,M]/,'\d')) 
  wait_until(15){ find("section", :text => re) }
end

Given /^the system is set up$/ do
  [MetaKey, MetaContext, MetaContextGroup, MetaKeyDefinition, MetaTerm, UsageTerm].each do |x|
    x.count.should > 0
  end
end

Then /^each of the following media types has its own representing icon according to the mappings in the file "([^"]*)"$/ do |file_path|
  dir = File.join(Rails.root, "app/assets/images/thumbnails")
  types = YAML.load File.read(File.join(Rails.root, file_path))
  types["icons"].each do |type|
    type["extensions"].each do |extension|
      base_extension = File.extname(type["icon"])
      target_file = File.join(dir, [File.basename(type["icon"], base_extension), ".", extension, base_extension].join)
      File.exists?(target_file).should be_true
    end
  end
end

When /^the grid layout is active$/ do
  find("#bar .layout a[data-type='grid']").click
end

############

When /^I upload a file with pdf mime type$/ do
  step 'I upload the file "features/data/files/test_pdf_for_metadata.pdf" relative to the Rails directory'
  steps %Q{
   And I go to the upload edit 
   And I fill in the metadata for entry number 1 as follows:
   |label    |value                       |
   |Titel    |A pdf document|
   |Rechte|myself             |
   And I follow "weiter..."
   And I follow "Import abschliessen"
  }
end

When /^I see a thumbnail of a media resource with pdf mime type$/ do
  wait_until { find(".doc") }
end

Then /^I see the first page of that pdf as thumbnail image$/ do
  page.evaluate_script('$(".doc img").attr("src").length').should > 0
end

When /^I upload a broken file with pdf mime type$/ do
  step 'I upload the file "features/data/files/broken_pdf.pdf" relative to the Rails directory'
  steps %Q{
   And I go to the upload edit 
   And I fill in the metadata for entry number 1 as follows:
   |label    |value                       |
   |Titel    |A pdf document|
   |Rechte|myself             |
   And I follow "weiter..."
   And I follow "Import abschliessen"
  }
end

Then /^I see a thumbnail placeholder for pdf$/ do
  page.evaluate_script('$(".doc img").attr("src").length').should > 0
end

Given /^a pdf resource$/ do
  step 'I upload the file "features/data/files/test_pdf_for_metadata.pdf" relative to the Rails directory'
  steps %Q{
   And I go to the upload edit 
   And I fill in the metadata for entry number 1 as follows:
   |label    |value                       |
   |Titel    |A pdf document|
   |Rechte|myself             |
   And I follow "weiter..."
   And I follow "Import abschliessen"
  }
end

Then /^I see that the pdf thumbnail is surrounded by a document frame$/ do
  wait_until do
    page.evaluate_script('$(".item_box.doc .thumb_box").css("background-position")') == "0px -243px" ||
    page.evaluate_script('$(".item_box.doc .thumb_box").css("background-position")') == "-85px -393px"
  end
end