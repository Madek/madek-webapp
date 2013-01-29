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
          value: Faker::Lorem.words.join(" "),
          type: type)
        field_set.find("textarea").set(meta_data[i][:value])

      when 'meta_datum_people' 
        # remove all existing 
        field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
        @people ||= Person.all
        random_person =  @people[rand @people.size]
        meta_data[i] = HashWithIndifferentAccess.new(
          value: random_person.to_s,
          type: type)
        field_set.find("input.form-autocomplete-person").set(random_person.to_s)
        wait_until{  field_set.all("a",text: random_person.to_s).size > 0 }
        field_set.find("a",text: random_person.to_s).click

      when 'meta_datum_date' 
        meta_data[i] = HashWithIndifferentAccess.new(
          value: Time.at(rand Time.now.tv_nsec).iso8601,
          type: type)
          field_set.find("input", visible: true).set(meta_data[i][:value])

      when 'meta_datum_keywords'
        # remove all existing 
        field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
        @kws ||= MetaTerm.joins(:keywords).select("de_ch").uniq.map(&:de_ch).sort
        random_kw = @kws[rand @kws.size]
        meta_data[i] = HashWithIndifferentAccess.new(
          value: random_kw,
          type: type)
        field_set.find("input", visible: true).set(random_kw)
        wait_until{  field_set.all("a",text: random_kw).size > 0 }
        field_set.find("a",text: random_kw).click

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
      when 'meta_datum_people' 
        expect(field_set.all("ul.multi-select-holder li",text: meta_data[i][:value]).size ).to eq 1
      when 'meta_datum_date' 
        expect(field_set.find("input", visible: true).value).to eq meta_data[i][:value]
      when 'meta_datum_keywords'
        expect(field_set.all("ul.multi-select-holder li",text: meta_data[i][:value]).size ).to eq 1
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



