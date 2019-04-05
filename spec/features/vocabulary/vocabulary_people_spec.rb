require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/vocabulary_shared'
include VocabularyShared

feature 'Vocabulary people' do

  scenario 'Check if shown' do
    create_vocabulary('vocabulary_a')

    create_people_meta_key('vocabulary_a', 'meta_key_aa')
    create_people_meta_key('vocabulary_a', 'meta_key_ab')

    create_person(firstname: 'a', lastname: 'b')
    create_person(firstname: 'c', lastname: 'd')

    create_resource_with_person_meta_data(
      person_meta_key: 'vocabulary_a:meta_key_aa',
      first_and_last_names: [
        { firstname: 'c', lastname: 'd' },
        { firstname: 'a', lastname: 'b' }
      ]
    )

    visit_vocabulary_people('vocabulary_a')

    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_people, active: true },
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )

    check_people(
      [
        {
          meta_key: 'meta_key_aa',
          names: [
            'a b',
            'c d'
          ]
        },
        {
          meta_key: 'meta_key_ab',
          names: []
        }
      ]
    )
  end

  scenario 'Check if shown empty' do
    create_vocabulary('vocabulary_a')
    visit_vocabulary_people('vocabulary_a')
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_people, active: true },
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )
  end

  def check_people(configs)
    configs.each do |c|
      check_people_meta_key(c)
    end
  end

  def check_people_meta_key(config)
    box = find('.ui-metadata-box', text: config[:meta_key])
    names = config[:names]

    if names.empty?
      box.find('div', text: I18n.t('vocabularies_no_people'))
    else
      names.each do |n|
        box.find('.ui-tag-cloud-item', text: n)
      end

    end
  end

  private

  def vocabulary_by_id(vocabulary_id)
    Vocabulary.find(vocabulary_id)
  end

  def visit_vocabulary_people(vocabulary_id)
    visit vocabulary_people_path(
      vocabulary_by_id(vocabulary_id)
    )
  end

  def create_vocabulary(vocabulary_id)
    FactoryGirl.create(:vocabulary, id: vocabulary_id)
  end

  def create_person(firstname: nil, lastname: nil)
    FactoryGirl.create(:person, first_name: firstname, last_name: lastname)
  end

  def create_resource_with_person_meta_data(
    person_meta_key: nil,
    first_and_last_names: nil
  )
    meta_key = MetaKey.find(person_meta_key)
    media_entry = FactoryGirl.create(:media_entry)

    persons = first_and_last_names.map do |fl|
      Person.find_by(first_name: fl[:firstname], last_name: fl[:lastname])
    end

    FactoryGirl.create(
      :meta_datum_people,
      media_entry: media_entry,
      meta_key: meta_key,
      people: persons)
  end

  def create_people_meta_key(vocabulary_id, meta_key_id)
    FactoryGirl.create(
      :meta_key_people,
      id: vocabulary_id + ':' + meta_key_id,
      labels: { de: meta_key_id })
  end
end
