require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Batch update media entries' do
  let(:vocabulary) do
    FactoryBot.create(:vocabulary,
                       id: Faker::Lorem.characters(number: 10),
                       enabled_for_public_view: true,
                       enabled_for_public_use: true)
  end
  let(:meta_key_text_1) do
    FactoryBot.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 10)}")
  end
  let(:meta_key_text_2) do
    FactoryBot.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 10)}")
  end
  let(:meta_key_text_3) do
    FactoryBot.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 10)}")
  end
  let(:meta_key_keywords) do
    FactoryBot.create(:meta_key_keywords,
                       is_extensible_list: true,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 10)}")
  end
  let(:meta_key_people) do
    FactoryBot.create(:meta_key_people,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(number: 10)}")
  end

  it 'successfully updates meta_data for all entries' do
    # NOTE: create more than 16 Keywords total to trigger the autocomplete!
    20.times { FactoryBot.create(:keyword, meta_key: meta_key_keywords) }

    user = FactoryBot.create :user

    me1 = FactoryBot.create :media_entry_with_image_media_file, :fat
    me2 = FactoryBot.create :media_entry_with_image_media_file, :fat

    [me1, me2].each do |me|
      me.user_permissions << FactoryBot.create(:media_entry_user_permission,
                                                get_metadata_and_previews: true,
                                                get_full_size: true,
                                                edit_metadata: true,
                                                user: user)
    end

    # case 1: same value for meta key present in both entries,
    # which will not be changed
    me1.meta_data << FactoryBot.create(:meta_datum_text,
                                        meta_key: meta_key_text_1,
                                        string: 'Meta Datum Text 1')
    me2.meta_data << FactoryBot.create(:meta_datum_text,
                                        meta_key: meta_key_text_1,
                                        string: 'Meta Datum Text 1')

    # case 2: value for a meta_key present only in one entry,
    # which will be changed
    me1.meta_data << FactoryBot.create(:meta_datum_text,
                                        meta_key: meta_key_text_2,
                                        string: 'Meta Datum Text 2')

    # case 3: value for a meta_key present only in one entry,
    # which will not be changed
    me1.meta_data << FactoryBot.create(:meta_datum_text,
                                        meta_key: meta_key_text_3,
                                        string: 'Meta Datum Text 3')

    # case 4: different values for a meta_key present in both entries,
    # which will be changed
    keyword_1 = FactoryBot.create(:keyword, meta_key: meta_key_keywords)
    keyword_2 = FactoryBot.create(:keyword, meta_key: meta_key_keywords)
    FactoryBot.create(:meta_datum_keywords,
                       media_entry: me1,
                       meta_key: meta_key_keywords,
                       keywords: [keyword_1])
    FactoryBot.create(:meta_datum_keywords,
                       media_entry: me2,
                       meta_key: meta_key_keywords,
                       keywords: [keyword_2])

    # case 5: same value for meta key present in both entries,
    # which will be deleted
    @person = FactoryBot.create(:person)
    me1.meta_data << FactoryBot.create(:meta_datum_people,
                                        meta_key: meta_key_people,
                                        people: [@person])
    me2.meta_data << FactoryBot.create(:meta_datum_people,
                                        meta_key: meta_key_people,
                                        people: [@person])

    ########################################################################

    sign_in_as user.login, user.password

    visit(
      batch_edit_meta_data_by_context_media_entries_path(
        id: [me1, me2],
        return_to: '/my'))

    ########################################################################

    find('.ui-tabs-item', text: I18n.t(:meta_data_form_all_data)).click

    within '.tab-content' do
      # case 1: do nothing

      # case 2
      @new_value_for_meta_key_text_2 = Faker::Lorem.words(number: 3).join(' ')
      find('fieldset', text: meta_key_text_2.label)
        .find('input')
        .set @new_value_for_meta_key_text_2

      # case 3: do nothing

      # case 4
      @new_value_for_meta_key_keywords = \
        [FactoryBot.create(:keyword, meta_key: meta_key_keywords).term]
      @new_value_for_meta_key_keywords.each do |val|
        autocomplete_and_choose_first \
          find('fieldset', text: meta_key_keywords.label),
          val
      end
      input = find('fieldset', text: meta_key_keywords.label).find('input')
      input.set('ontheflykeyword')
      input.native.send_keys(:enter)
      @new_value_for_meta_key_keywords << 'ontheflykeyword'

      # case 5: delete all values
      field = find('fieldset', text: meta_key_people.label)
      field.find('.form-label').click # force-close all autocompletes
      field
        .all('.multi-select-tag-remove')
        .each(&:click)

      submit_form
    end

    expect(page).to have_selector '.success.ui-alert'

    ########################################################################

    me1.reload

    # case 1:
    expect(me1.meta_data.find_by_meta_key_id(meta_key_text_1.id).value)
      .to be == 'Meta Datum Text 1'

    # case 2:
    expect(me1.meta_data.find_by_meta_key_id(meta_key_text_2.id).value)
      .to be == @new_value_for_meta_key_text_2

    # case 3:
    expect(me1.meta_data.find_by_meta_key_id(meta_key_text_3.id).value)
      .to be == 'Meta Datum Text 3'

    # case 4:
    expect(
      me1.meta_data.find_by_meta_key_id(meta_key_keywords.id).value.map(&:term)
    ).to match_array @new_value_for_meta_key_keywords

    # case 5:
    expect(
      me1.meta_data.find_by_meta_key_id(meta_key_people.id).value.map(&:to_s)
    ).to match_array [@person.to_s]

    ########################################################################

    me2.reload

    # case 1:
    expect(me2.meta_data.find_by_meta_key_id(meta_key_text_1.id).value)
      .to be == 'Meta Datum Text 1'

    # case 2:
    expect(me2.meta_data.find_by_meta_key_id(meta_key_text_2.id).value)
      .to be == @new_value_for_meta_key_text_2

    # case 3:
    expect(me2.meta_data.find_by_meta_key_id(meta_key_text_3.id)).not_to be

    # case 4:
    expect(
      me2.meta_data.find_by_meta_key_id(meta_key_keywords.id).value.map(&:term)
    ).to match_array @new_value_for_meta_key_keywords

    # case 5:
    expect(
      me2.meta_data.find_by_meta_key_id(meta_key_people.id).value.map(&:to_s)
    ).to match_array [@person.to_s]
  end
end
