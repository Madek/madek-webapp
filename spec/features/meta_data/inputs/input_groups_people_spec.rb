require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user

  end

  context 'MetaDatumPeople' do
    background do
      @vocabulary = FactoryGirl.create(:vocabulary)
      @meta_key = FactoryGirl.create(:meta_key_people)
      @context_key = FactoryGirl.create(:context_key, meta_key: @meta_key)
      AppSettings.first.update_attributes!(
        contexts_for_entry_edit: [@context_key.context_id],
        context_for_entry_summary: @context_key.context_id)
      FactoryGirl.create(
        :meta_datum_people,
        meta_key: @meta_key,
        media_entry: @media_entry)
    end

    example 'add new Person' do
      visit edit_context_meta_data_media_entry_path(@media_entry)

      within('form') do
        within('.ui-form-group', text: @context_key.label) do
          add_new_person_to_field
        end
        submit_form
      end

      wait_until { current_path == media_entry_path(@media_entry) }
      within('.ui-media-overview-metadata') do
        expect(find('.media-data-title', text: @context_key.label)).to be
        expect(find('.media-data-content', text: 'Street Artist (Banksy)')).to be
      end
    end

    example 'add new PeopleGroup' do
      visit edit_context_meta_data_media_entry_path(@media_entry)

      within('form') do
        within('.ui-form-group', text: @context_key.label) do
          add_new_peoplegroup_to_field
        end
        submit_form
      end

      wait_until { current_path == media_entry_path(@media_entry) }
      within('.ui-media-overview-metadata') do
        expect(find('.media-data-title', text: @context_key.label)).to be
        expect(find('.media-data-content', text: 'Saalschutz')).to be
      end
    end

    example 'add new Person and PeopleGroup' do
      visit edit_context_meta_data_media_entry_path(@media_entry)

      within('form') do
        within('.ui-form-group', text: @context_key.label) do
          add_new_person_to_field
          add_new_peoplegroup_to_field
        end
        submit_form
      end

      wait_until { current_path == media_entry_path(@media_entry) }
      within('.ui-media-overview-metadata') do
        expect(find('.media-data-title', text: @context_key.label)).to be
        expect(find('.media-data-content', text: 'Street Artist (Banksy)')).to be
        expect(find('.media-data-content', text: 'Saalschutz')).to be
      end
    end

    example 'add PeopleInstitutionalGroup' do
      @group_person = FactoryGirl.create(:people_instgroup)
      group_label = @group_person.last_name

      @meta_key = FactoryGirl.create(:meta_key_people_instgroup)
      @context_key = FactoryGirl.create(:context_key, meta_key: @meta_key)
      AppSettings.first.update_attributes!(
        contexts_for_entry_edit: [@context_key.context_id],
        context_for_entry_summary: @context_key.context_id)
      FactoryGirl.create(
        :meta_datum_people,
        meta_key: @meta_key, media_entry: @media_entry)

      visit edit_context_meta_data_media_entry_path(@media_entry)

      within('form') do
        form_group = find('.ui-form-group', text: @context_key.label)
        autocomplete_and_choose_first(form_group, group_label)
        group_tag = find('.multi-select-tag', text: group_label)
        expect(group_tag.text).to eq(group_label)
        submit_form
      end

      wait_until { current_path == media_entry_path(@media_entry) }
      within('.ui-media-overview-metadata') do
        expect(find('.media-data-content', text: group_label)).to be
      end
    end

  end

end

private

def add_new_person_to_field
  find('.form-widget-toggle').click
  person_form = find(
    "#media_entry_meta_data_#{@meta_key.id}_new_person-pane-Person"
      .tr(':', '_'))
  within(person_form) do
    fill_in 'first_name', with: 'Street'
    fill_in 'last_name', with: 'Artist'
    fill_in 'pseudonym', with: 'Banksy'
    click_on I18n.t(:meta_data_input_new_person_add)
  end

  within('.multi-select-holder') do
    expect(find('.multi-select-tag', text: 'Street Artist (Banksy)')).to be
  end
end

def add_new_peoplegroup_to_field
  find('.form-widget-toggle').click
  base_id = "#media_entry_meta_data_#{@meta_key.id}".tr(':', '_')
  peoplegroup_toggle = find("#{base_id}_new_person-tab-PeopleGroup")
  peoplegroup_toggle.click
  peoplegroup_form = find("#{base_id}_new_person-pane-PeopleGroup")
  within(peoplegroup_form) do
    fill_in 'first_name', with: 'Saalschutz'
    click_on I18n.t(:meta_data_input_new_group_add)
  end

  within('.multi-select-holder') do
    expect(find('.multi-select-tag', text: 'Saalschutz')).to be
  end
end
