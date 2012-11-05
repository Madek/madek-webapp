When /^I switch to database authentication$/ do
  unless all(".tab[data-ref='local_database']").empty?
    find(".tab[data-ref='local_database']").click
  end
end

Then /^I'm logged in$/ do
  step "I see a list of content owned by me"
end
