require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/ui_helpers_spec'

include UIHelpers

feature 'Batch update media entries' do
  let(:vocabulary) do
    FactoryGirl.create(:vocabulary,
                       id: Faker::Lorem.characters(10),
                       enabled_for_public_view: true,
                       enabled_for_public_use: true)
  end
  let(:meta_key_text_1) do
    FactoryGirl.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end
  let(:meta_key_text_2) do
    FactoryGirl.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end
  let(:meta_key_text_3) do
    FactoryGirl.create(:meta_key_text,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end
  let(:meta_key_keywords) do
    FactoryGirl.create(:meta_key_keywords,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end
  let(:meta_key_people) do
    FactoryGirl.create(:meta_key_people,
                       vocabulary: vocabulary,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(10)}")
  end

  it 'successfully updates meta_data for all entries', browser: :firefox do
    # NOTE: create more than 16 Keywords total to trigger the autocomplete!
    20.times { FactoryGirl.create(:keyword, meta_key: meta_key_keywords) }

    user = FactoryGirl.create :user

    me1 = FactoryGirl.create :media_entry_with_image_media_file, :fat
    me2 = FactoryGirl.create :media_entry_with_image_media_file, :fat

    [me1, me2].each do |me|
      me.user_permissions << FactoryGirl.create(:media_entry_user_permission,
                                                get_metadata_and_previews: true,
                                                get_full_size: true,
                                                edit_metadata: true,
                                                user: user)
    end

    # case 1: same value for meta key present in both entries,
    # which will not be changed
    me1.meta_data << FactoryGirl.create(:meta_datum_text,
                                        meta_key: meta_key_text_1,
                                        string: 'Meta Datum Text 1')
    me2.meta_data << FactoryGirl.create(:meta_datum_text,
                                        meta_key: meta_key_text_1,
                                        string: 'Meta Datum Text 1')

    # case 2: value for a meta_key present only in one entry,
    # which will be changed
    me1.meta_data << FactoryGirl.create(:meta_datum_text,
                                        meta_key: meta_key_text_2,
                                        string: 'Meta Datum Text 2')

    # case 3: value for a meta_key present only in one entry,
    # which will not be changed
    me1.meta_data << FactoryGirl.create(:meta_datum_text,
                                        meta_key: meta_key_text_3,
                                        string: 'Meta Datum Text 3')

    # case 4: different values for a meta_key present in both entries,
    # which will be changed
    keyword_1 = FactoryGirl.create(:keyword, meta_key: meta_key_keywords)
    keyword_2 = FactoryGirl.create(:keyword, meta_key: meta_key_keywords)
    FactoryGirl.create(:meta_datum_keywords,
                       media_entry: me1,
                       meta_key: meta_key_keywords,
                       keywords: [keyword_1])
    FactoryGirl.create(:meta_datum_keywords,
                       media_entry: me2,
                       meta_key: meta_key_keywords,
                       keywords: [keyword_2])

    # case 5: same value for meta key present in both entries,
    # which will be deleted
    @person = FactoryGirl.create(:person)
    me1.meta_data << FactoryGirl.create(:meta_datum_people,
                                        meta_key: meta_key_people,
                                        people: [@person])
    me2.meta_data << FactoryGirl.create(:meta_datum_people,
                                        meta_key: meta_key_people,
                                        people: [@person])

    ###############################################################################

    sign_in_as user.login, user.password

    visit batch_edit_meta_data_media_entries_path(id: [me1, me2])

    ###############################################################################

    within "[name='batch_resource_meta_data']" do
      # case 1: do nothing

      # case 2
      @new_value_for_meta_key_text_2 = Faker::Lorem.words(3).join(' ')
      find('fieldset', text: meta_key_text_2.label)
        .find('input')
        .set @new_value_for_meta_key_text_2

      # case 3: do nothing

      # case 4
      @new_value_for_meta_key_keywords = \
        [FactoryGirl.create(:keyword, meta_key: meta_key_keywords)].map(&:term)
      @new_value_for_meta_key_keywords.each do |val|
        autocomplete_and_choose_first \
          find('fieldset', text: meta_key_keywords.label),
          val
      end

      # case 5: delete all values
      find('fieldset', text: meta_key_people.label)
        .all('.multi-select-tag-remove')
        .each(&:click)

      submit_form
    end

    expect(page).to have_selector '.success.ui-alert'

    ###############################################################################

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

    ###############################################################################

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
