When /^(?:|I )open the "(.+)" set$/ do |title|
  id = nil
  Media::Set.all.each do |set|
    if set.title == title
      id = set.id
      break
    end
  end
  visit media_set_path(id)
end

When /^(?:|I )open the "(.+)" entry/ do |title|
  id = nil
  MediaEntry.all.each do |entry|
    if entry.title == title
      id = entry.id
      break
    end
  end
  visit media_entry_path(id)
end

When /^(?:|I )open the selection widget in "(.+)"$/ do |container|
  find("#{container} .has-selection-widget").click
end

When /^(?:|I )select "(.+)" as parent set$/ do |label|
  find("input##{label}:not(selected)").click
end

When /^(?:|I )deselect "(.+)" as parent set$/ do |label|
  raise "#{label} is not selected so you can not deselect it" unless find("input##{label}").checked?
  find("input##{label}").click
end

When /^(?:|I )submit the selection widget$/ do
  find(".widget .submit").click
end