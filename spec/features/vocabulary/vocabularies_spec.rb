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

    example 'with instance-specific Vocabularies (personas)' do
      visit vocabularies_path

      # expect correct list for personas data:
      expect(displayed_vocabulary_index).to eq [
        { title: 'ZHdK',
          description: nil,
          meta_keys: [
            'Bereich ZHdK', 'ZHdK-Projekttyp', 'Studienabschnitt',
            'Projekttitel', 'Dozierende/Projektleitung'] },
        { title: 'Werk',
          description: nil,
          meta_keys: [
            'Gattung',
            'Bildlegende',
            'Bemerkung',
            'Internet Links (URL)',
            'Standort/Aufführungsort',
            'Stadt',
            'Kanton/Bundesland',
            'Land',
            'ISO-Ländercode',
            'Mitwirkende / weitere Personen',
            'Porträtierte Person/en',
            'Partner / beteiligte Institutionen',
            'Auftrag durch'] },
        { title: 'Nutzung', description: nil, meta_keys: [
          'Bearbeitet durch', 'Geändert am', 'Enthalten in', 'Enthält'] },
        { title: 'Credits',
          description: nil,
          meta_keys: [
            'Copyright-Status',
            'Nutzungsbedingungen',
            'URL für Copyright-Informationen',
            'Quelle',
            'Angeboten durch',
            'Beschreibung durch',
            'Beschreibung durch (vor dem Hochladen ins Medienarchiv)'] },
        { title: 'Medium',
          description: nil,
          meta_keys: [
            'Medienersteller/in',
            'Adresse',
            'Stadt',
            'Kanton/Bundesland',
            'Postleitzahl',
            'Land',
            'Telefonnummer',
            'E-Mail-Adresse',
            'Website',
            'Berufsbezeichnung',
            'Erstellungsdatum',
            'Dimensionen',
            'Material/Format'] },
        {
          title: 'Core', description: nil, meta_keys: [
            'Eigentümer/in im Medienarchiv']
        },
        { title: 'Set', description: nil, meta_keys: ['Erstellt am'] },
        {
          title: 'Madek Core',
          description: 'Das Core-Vokabular ist fester Bestandteil der Software '\
            'Madek. Es enthält die wichtigsten Metadaten für die Beschreibung '\
            'von Medieninhalten und ist vordefiniert und unveränderbar.',
          meta_keys: [
            'Titel', 'Untertitel', 'Autor/in', 'Datierung', 'Schlagworte',
            'Beschreibung', 'Urheberrechtshinweis', 'Ältere Version'
          ]
        }
      ]
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
            ['scope', 'Entries, Sets']] },
        { title: 'Untertitel',
          table: [
            ['ID', 'madek_core:subtitle'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']] },
        { title: 'Autor/in',
          table: [
            ['ID', 'madek_core:authors'],
            ['type', 'People (Person, PeopleGroup)'],
            ['scope', 'Entries, Sets']] },
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
        { title: 'Urheberrechtshinweis',
          table: [
            ['ID', 'madek_core:copyright_notice'],
            ['type', 'Text'],
            ['scope', 'Entries, Sets']] },
        { title: 'Ältere Version',
          table: [
            ['ID', 'madek_core:is_new_version_of'],
            ['type', 'MediaEntry'],
            ['description', 'Ältere Version verfügbar? UUID und optional Art der Änderung '\
              'eingeben.'],
            ['hint', 'UUID of previous version'],
            ['scope', 'Entries']] }
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
      displayed_list = all('.row .col1of3 > div')
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

  def displayed_vocabulary_index
    rows = all('.row')
    rows.map do |row|
      row.all('.col1of3').map do |item|
        {
          title: item.find('.title-l').text,
          description: item.all('p').first.try(:text),
          meta_keys: item.find('ul').all('li').map(&:text)
        }
      end
    end.flatten
  end

  def with_disabled_constraints
    ActiveRecord::Base.connection.execute 'SET session_replication_role = REPLICA;'
    yield
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
  end

  def clean_db
    with_disabled_constraints do
      Vocabulary.all.reject { |v| v.id == 'madek_core' }.each(&:destroy!)
    end
    IoMapping.delete_all
    Keyword.delete_all
  end

end
