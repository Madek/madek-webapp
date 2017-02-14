require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Vocabularies' do

  describe 'VocabulariesIndex' do

    example 'Core Vocabulary, with empty DB' do
      clean_db
      core_vocab = Vocabulary.find('madek_core')

      visit vocabularies_path
      expect_listed_vocabularies [{
        title: core_vocab.label, # 'Madek Core'
        text: core_vocab.description
      }]
    end

    example 'with instance-specific Vocabularies' do
      pending 'no test'
      fail
    end

  end

  describe 'VocabularyShow' do
    example 'Core Vocabulary, with empty DB' do
      clean_db
      core_vocab = Vocabulary.find('madek_core')

      visit vocabulary_path(core_vocab)
      expect_listed_meta_keys [
        { title: 'Titel',
          table: [
            ['ID', 'madek_core:title'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']]
        },
        { title: 'Untertitel',
          table: [
            ['ID', 'madek_core:subtitle'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']]
        },
        { title: 'Autor/in',
          table: [
            ['ID', 'madek_core:authors'],
            ['type', 'People (Person, PeopleGroup)'],
            ['scope', 'Entries, Sets']]
        },
        { title: 'Datierung',
          table: [
            ['ID', 'madek_core:portrayed_object_date'],
            ['type', 'TextDate'],
            ['scope', 'Entries, Sets']] },
        { title: 'Schlagworte',
          table: [
            ['ID', 'madek_core:keywords'],
            ['type', 'Keywords'],
            ['scope', 'Entries, Sets']] },
        { title: 'Beschreibung',
          table: [
            ['ID', 'madek_core:description'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']] },
        { title: 'Rechteinhaber/in',
          table: [
            ['ID', 'madek_core:copyright_notice'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']] }
      ]
    end

    example 'with instance-specific Vocabularies' do
      pending 'no test'
      fail
    end

  end

  private

  def expect_listed_vocabularies(expected_list)
    # get list, check length, order, contents
    within('.app-body') do
      displayed_list = all('.row .col1of3 div')
      expect(displayed_list.length).to be expected_list.length
      expected_list.each.with_index do |expected, index|
        expect(displayed_list[index].find('.title-l').text).to eq expected[:title]
        expect(displayed_list[index].find('p').text).to eq expected[:text]
      end
    end
  end

  def expect_listed_meta_keys(expected_list)
    # get list, check length, order, contents
    within('.app-body') do
      displayed_list = all('.row .col1of3 div')
      expect(displayed_list.length).to be expected_list.length
      expected_list.each.with_index do |expected, index|
        expect(displayed_list[index].find('.title-m').text).to eq expected[:title]
        expect(get_table_contents(displayed_list[index].find('table')))
          .to eq expected[:table]
      end
    end
  end

  def get_table_contents(table) # parse html table as array
    table.all('tbody tr').map { |row| row.all('td').map(&:text) }
  end

  def clean_db
    Vocabulary.all.reject { |v| v.id == 'madek_core' }.each(&:destroy!)
    IoMapping.delete_all
    Keyword.delete_all
  end

end
