
Then /^Set A inherits all the contexts of the set B$/ do
  find("a[href='#{inheritable_contexts_media_set_path(@media_set_a)}']").click
  find("h2", text: 'Diesem Set sind zusätzliche Kontexte mit Metadaten zugewiesen')
  @media_set_b.individual_contexts.each do |context|
    page.should have_content context.label.to_s
    find("a[href='#{context_path context}']")
  end
end

Then /^Set A bequests all contexts to every media entry of its children$/  do

  @media_set_a.child_media_resources.media_entries.accessible_by_user(@current_user,:view).each do |media_entry|
    visit context_group_media_entry_path media_entry, "Kontexte"
    @media_set_a.individual_contexts.each do |context|
      page.should have_content context.label.to_s
    end
  end
end


