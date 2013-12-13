# -*- encoding : utf-8 -*-
#
Then /^I get rid of the anoying browser warning$/ do
  find("#not_supported_warning button").click()
end


Then /^I go to (.*?)$/ do |page|
  
  visit case page


    # a ################################################

    when "a list of resources"
      media_resources_path

    when "a search result page"
      result_search_path()

    # my ################################################

    when "my groups"
      my_groups_path

    # the e ################################################
    when "the edit-page of my first media_entry"
      @media_entry = @me.media_entries.reorder(:id).first
      edit_media_resource_path(@media_entry)

    when "edit multiple media entries using the batch"
      @collection = Collection.add @me.media_entries.map(&:id)
      edit_multiple_media_entries_path(:collection_id => @collection[:id])

    when "the explore page"
      explore_path

    when "the explore contexts page"
      explore_contexts_path


    # the h ################################################
    when "the home page"
      root_path

    # the l ################################################
    when "the list of entrusted media resources"
      my_entrusted_media_resources_path

    # the p ################################################
    when "the page of the media_entry"
      media_entry_path @media_entry

    when "the page of the media_entry in the admin interface"
      admin_media_entry_path @media_entry

    # the m ################################################
    when "the media_resources with filter_panel" 
      media_resources_path(filterpanel: true) 

    # the s ################################################
    when "the search page"
      search_path

    when "the context's abstract page"
      context_abstract_path @context

    when "the context's vocabulary page"
      context_vocabulary_path @context

    when "the import page"
      import_path

    else
      raise "#{page} not found"
  end
end

