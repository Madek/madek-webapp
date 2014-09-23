Then /^each meta\-data value in each context should be equal to the one set previously$/ do
  all("ul.contexts li").each do |context|
    context.find("a").click()
    @meta_data = @meta_data_by_context[context[:'data-context-id']]
    step 'each meta-data value should be equal to the one set previously'
  end
end

Then /^each meta\-data value should be equal to the one set previously$/ do
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    type = field_set[:'data-type']
    meta_key = field_set[:'data-meta-key']

    case type
    when 'meta_datum_string'
      if field_set.all("textarea").size > 0
        expect(field_set.find("textarea").value).to eq @meta_data[i][:value]
      else
        expect(field_set.find("input[type='text']").value).to eq @meta_data[i][:value]
      end
    when 'meta_datum_people' 
      expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
    when 'meta_datum_date' 
      expect(field_set.find("input", visible: true).value).to eq @meta_data[i][:value]
    when 'meta_datum_keywords'
      #expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
      expect(field_set.all("ul.multi-select-holder li",text: @meta_data[i][:value]).size ).to eq 1
    when 'meta_datum_meta_terms'
      if field_set['data-is-extensible-list']
        expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
      else
        expect(field_set.all("input", type: 'checkbox', visible: true,checked: true).first.find(:xpath,".//..").text).to eq @meta_data[i][:value]
      end
    when 'meta_datum_institutional_groups' 
      expect( stable_part_of_meta_datum_institutional_group(field_set.first("ul.multi-select-holder li.meta-term").text)).to \
        eq stable_part_of_meta_datum_institutional_group(@meta_data[i][:value])
    else
      raise "Implement this case"
    end
  end
end
