Then /^I can see every meta\-data\-value somewhere on the page$/ do
  @meta_data.each do |meta_context_name,meta_data|
    meta_data.select{|md| not md.nil?}.map{|md| md[:value]}.each do |value|
      expect(page).to have_content value
    end
  end
end

Given /^I change the value of each meta\-data field$/  do

  @meta_data=HashWithIndifferentAccess.new

  all("ul.contexts li").each do |context|
    context.find("a").click()
    meta_data= []
    all("form fieldset",visible: true).each_with_index do |field_set,i|
      type = field_set[:'data-type']

      case type
      when 'meta_datum_string'
        meta_data[i] = HashWithIndifferentAccess.new(
          value: Faker::Lorem.words.join(" "))
          field_set.find("textarea").set(meta_data[i][:value])
      else
        # TODO
      end

    end
    @meta_data[context[:'data-context-name']] = meta_data
  end
end

Then /^each meta\-data value should be equal to the one set previously$/ do
  all("ul.contexts li").each do |context|
    context.find("a").click()
    meta_data= @meta_data[context[:'data-context-name']]
    all("form fieldset",visible: true).each_with_index do |field_set,i|
      type = field_set[:'data-type']
      case type
      when 'meta_datum_string'
        expect(field_set.find("textarea").value).to eq meta_data[i][:value]
      else
        # TODO
      end
    end
  end
end

And /^I go to the edit-page of my first media_entry$/ do
  @media_entry = @me.media_entries.reorder(:id).first
  visit edit_media_resource_path @media_entry
end

Then /^I am on the page of my first media_entry$/ do
  @media_entry = @me.media_entries.reorder(:id).first
  expect(current_path).to eq  media_entry_path(@media_entry)
end



