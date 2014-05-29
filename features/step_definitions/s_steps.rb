
Then /^all the contexts of the set B are listed for set A$/ do
  find("a[href='#{context_media_set_path(@media_set_a, @media_set_a.individual_contexts.first)}']").click
  find("p", text: 'Vokabular verfügbar')
  @media_set_b.individual_contexts.each do |context|
    page.should have_content context.label.to_s
    find("a[href='#{context_path context}']")
  end
end

Then /^Set A bequests all contexts to every media entry of its children$/  do

  @media_set_a.child_media_resources.media_entries.accessible_by_user(@current_user,:view).each do |media_entry|
    visit contexts_media_entry_path media_entry
    @media_set_a.individual_contexts.each do |context|
      page.should have_content context.label.to_s
    end
  end
end

