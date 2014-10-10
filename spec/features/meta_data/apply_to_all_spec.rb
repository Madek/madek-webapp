require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'import', 'shared.rb')

feature 'Applying meta data to other media entries' do
  include Features::Import::Shared

  background { @current_user = sign_in_as 'Normin' }

  scenario 'Possibility to apply meta data to other media entries', browser: :firefox do
    upload_some_media_entries
    click_button 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    find('.apply-to-all a', match: :first).click
    find("a[data-overwrite='true']")
    find("a[data-overwrite='false']")
  end

  scenario 'Overwriting meta data during apply all during import', browser: :firefox do
    upload_some_media_entries
    click_button 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    change_value_of_each_visible_meta_data
    apply_meta_datum_field_values_on_other_media_entries_using_overwrite_method
  end

  scenario 'Applying only on empty meta data fields during import', browser: :firefox do
    upload_some_media_entries
    click_button 'Berechtigungen speichern'
    wait_for_ajax
    assert_exact_url_path '/import/meta_data'
    change_value_of_each_visible_meta_data
    remember_meta_data_values_before_apply
    apply_meta_datum_field_values_on_other_media_entries_using_apply_on_empty_method
    expect_other_media_entries_to_have_the_same_meta_data_in_fields_empty_before
  end

  def apply_meta_datum_field_values_on_other_media_entries_using_overwrite_method
    all('form fieldset').each_with_index do |field_set, i|
      within field_set do
        find('.apply-to-all a').click
        find("a[data-overwrite='true']").click
        expect( all(".icon-checkmark").size ).to be > 0
      end
    end
  end

  def apply_meta_datum_field_values_on_other_media_entries_using_apply_on_empty_method
    all('form fieldset').each_with_index do |field_set, i|
      within field_set do
        find('.apply-to-all a').click
        find("a[data-overwrite='false']").click
        find('.icon-checkmark')
      end
    end
  end

  def change_value_of_each_visible_meta_data
    @meta_data = []
    all('form fieldset').each_with_index do |field_set, i|
      type = field_set[:'data-type']
      meta_key = field_set[:'data-meta-key']

      case type
      when 'meta_datum_string'
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: Faker::Lorem.words.join(' '),
          meta_key: meta_key,
          type: type)
        if field_set.all('textarea').size > 0
          field_set.find('textarea').set(@meta_data[i][:value])
        else
          field_set.find("input[type='text']").set(@meta_data[i][:value])
        end

      when 'meta_datum_people'
        # remove all existing
        field_set.all('.multi-select li a.multi-select-tag-remove').each { |a| a.click }
        @people ||= Person.all
        random_person =  @people[rand @people.size]
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: random_person.to_s,
          meta_key: meta_key,
          type: type)
        field_set.find('input.form-autocomplete-person').set(random_person.to_s)
        page.execute_script %Q{ $("input.form-autocomplete-person").trigger("change") }
        within field_set do
          find('a', text: random_person.to_s, match: :first)
          find('a', text: random_person.to_s, match: :first).click
        end

      when 'meta_datum_date'
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: Time.at(rand Time.now.tv_nsec).iso8601,
          meta_key: meta_key,
          type: type)
          field_set.find('input', visible: true).set(@meta_data[i][:value])

      when 'meta_datum_keywords'

        field_set.all('.multi-select li a.multi-select-tag-remove').each { |a| a.click }
        @kws ||= KeywordTerm.joins(:keywords).select('term').uniq.map(&:term).sort
        random_kw = @kws[rand @kws.size]
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: random_kw,
          meta_key: meta_key,
          type: type)
        field_set.find('input', visible: true).set(random_kw)
        page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
        within field_set do
          find('a', text: random_kw)
          find('a', text: random_kw).click
        end

      when 'meta_datum_meta_terms'
        if field_set['data-is-extensible-list']
          field_set.all('.multi-select li a.multi-select-tag-remove').each { |a| a.click }
          field_set.find('input', visible: true).click
          page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
          expect( field_set.all('ul.ui-autocomplete li a', visible: true).size ).to be > 0
          targets = field_set.all('ul.ui-autocomplete li a', visible: true)
          targets[rand targets.size].click
          within field_set do
            find('ul.multi-select-holder li.meta-term')
          end
          @meta_data[i] = HashWithIndifferentAccess.new(
            value: field_set.first('ul.multi-select-holder li.meta-term').text, 
            type: type,
            meta_key: meta_key) 
        else
          checkboxes = field_set.all('input', type: 'checkbox', visible: true)
          checkboxes.each { |c| c.set false }
          checkboxes[rand checkboxes.size].click
          @meta_data[i] = HashWithIndifferentAccess.new(
            value: field_set.all('input', type: 'checkbox', visible: true, checked: true).first.find(:xpath, './/..').text,
            meta_key: meta_key,
            type: type) 
        end

      when 'meta_datum_institutional_groups' 
        field_set.all('.multi-select li a.multi-select-tag-remove').each{|a| a.click}
        field_set.find('input', visible: true).click
        directly_chooseable= field_set.all('ul.ui-autocomplete li:not(.has-navigator) a', visible: true)
        directly_chooseable[rand directly_chooseable.size].click
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: field_set.first('ul.multi-select-holder li.meta-term').text, 
          type: type,
          meta_key: meta_key) 
      else
        raise 'Implement this case' 
      end

      Rails.logger.info ['setting metadata filed value', field_set[:'data-meta-key'], @meta_data[i] ]
    end
  end

  def expect_other_media_entries_to_have_the_same_meta_data_in_fields_empty_before
    reference_media_entry = MediaEntryIncomplete.find( find('.ui-resource[data-id]', match: :first)['data-id'] )
    @current_user.media_resources.where(:type => 'MediaEntryIncomplete').each do |media_entry|
      find(".ui-resource[data-id='#{media_entry.id}']").click
      @meta_data_before_apply[media_entry.id].each do |meta_datum|
        resource_value = MediaResource.find(meta_datum[:media_resource_id]).meta_data.get(meta_datum[:meta_key_id]).to_s
        referenced_value = reference_media_entry.meta_data.get(meta_datum[:meta_key_id]).to_s
        Rails.logger.info ['meta_datum:', meta_datum, 'resource_value:', resource_value, 'referenced_value', referenced_value]
        if meta_datum[:value].blank?
          expect(resource_value).to eq(referenced_value)
        elsif media_entry.id != reference_media_entry.id
          expect(resource_value).not_to eq(referenced_value)
        end
      end
    end
  end

  def remember_meta_data_values_before_apply
    @meta_data_before_apply = {}
    @current_user.media_resources.where(type: 'MediaEntryIncomplete').each do |mr|
      @meta_data_before_apply[mr.id] = []
      @meta_data.each do |md|
        meta_datum = mr.meta_data.get(md['meta_key'], true)
        @meta_data_before_apply[mr.id] << {
          value: meta_datum.value, 
          meta_key_id: meta_datum.meta_key_id,
          media_resource_id: mr.id
        }
      end
    end
  end

  def upload_some_media_entries
    visit import_path
    attach_test_file 'images/berlin_wall_01.jpg'
    attach_test_file 'images/berlin_wall_02.jpg'
    attach_test_file 'images/date_should_be_1990.jpg'
    start_uploading
    expect_import_permissions_page
  end
end
