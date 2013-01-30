When /^I go to (.*?)$/ do |page|
  
  visit case page

    when "my groups"
      my_groups_path

    when "the home page"
      root_path

    when "the explore page"
      explore_path

    when "the explore contexts page"
      explore_contexts_path

    when "the search page"
      search_path

    when "the context's abstract page"
      context_abstract_path @context

    when "the context's vocabulary page"
      context_vocabulary_path @context

    else
      raise "#{page} not found"
  end
end