require 'spec_helper'

describe Presenters::MediaEntries::MediaEntryRdfExport do
  before { truncate_tables }
  let(:user) { create :user }
  let(:title) { Faker::Name.title }
  let(:media_entry) { create(:media_entry_with_title, responsible_user: user, title: title) }
  let(:vocabulary) { create(:vocabulary) }
  let!(:meta_datum_text_date) do
    create(:meta_datum_text_date, string: Time.current, media_entry: media_entry)
  end
  let(:keyword_1) { create(:keyword) }
  let(:keyword_2) { create(:keyword) }
  let(:keyword_external_uri) { Faker::Internet.url }
  let(:keyword_with_external_uri) { create(:keyword, external_uris: [keyword_external_uri]) }
  let!(:meta_datum_keywords) do
    create(
      :meta_datum_keywords,
      media_entry: media_entry, keywords: [keyword_1, keyword_2, keyword_with_external_uri]
    )
  end
  let(:person_1) { create(:person) }
  let(:person_2) { create(:person) }
  let(:person_external_uri) { Faker::Internet.url }
  let(:person_with_external_uri) { create(:person, external_uris: [person_external_uri]) }
  let!(:meta_datum_people) do
    create(
      :meta_datum_people,
      media_entry: media_entry, people: [person_1, person_2, person_with_external_uri]
    )
  end
  let(:base_url) { 'http://localhost:1234' }
  subject { Presenters::MediaEntries::MediaEntryRdfExport.new(media_entry, user) }

  before { allow(Settings).to receive(:madek_external_base_url).and_return(base_url) }

  describe '#json_ld' do
    let(:json) { subject.json_ld }

    it 'returns correct JSON-LD' do
      expect(json.keys).to contain_exactly('@context', '@graph')
      expect(json.fetch('@context')).to be_a(Hash)
      expect(json.fetch('@graph')).to be_an(Array)
    end

    it 'returns correct @context node' do
      expect(json.fetch('@context').keys).to contain_exactly(
        '@base',
        'madek',
        'madek_core',
        'madek_system',
        'Keyword',
        'rdfs',
        'owl',
        'test'
      )
      expect(json.dig('@context', '@base')).to eq(base_url + '/')
      expect(json.dig('@context', 'madek')).to eq(base_url + '/ns#')
      expect(json.dig('@context', 'madek_core')).to eq(base_url + '/vocabulary/madek_core:')
      expect(json.dig('@context', 'madek_system')).to eq(base_url + '/vocabulary/madek_system:')
      expect(json.dig('@context', 'Keyword')).to eq(base_url + '/vocabulary/keyword/')
      expect(json.dig('@context', 'rdfs')).to eq('http://www.w3.org/2000/01/rdf-schema#')
      expect(json.dig('@context', 'owl')).to eq('http://www.w3.org/2002/07/owl#')
      expect(json.dig('@context', 'test')).to eq(base_url + '/vocabulary/test:')
    end

    it 'returns correct @graph node' do
      entry_md, *related_md = json.fetch('@graph')

      expect(entry_md).to be_a(Hash)
      expect(entry_md.fetch('@id')).to eq(base_url + '/entries/' + media_entry.id)
      expect(entry_md.fetch('@type')).to eq('madek:MediaEntry')

      expect(entry_md.fetch('madek_core:title')).to be_a(Hash)
      expect(entry_md.fetch('madek_core:title').keys).to contain_exactly('@value', '@type')
      expect(entry_md.dig('madek_core:title', '@value')).to eq(title)
      expect(entry_md.dig('madek_core:title', '@type')).to eq('madek:MetaDatum::Text')

      expect(entry_md.fetch('test:textdate')).to be_a(Hash)
      expect(entry_md.fetch('test:textdate').keys).to contain_exactly('@value', '@type')
      expect(entry_md.dig('test:textdate', '@value')).to eq(meta_datum_text_date.string)
      expect(entry_md.dig('test:textdate', '@type')).to eq('madek:MetaDatum::TextDate')

      expect(entry_md.fetch('test:keywords')).to be_an(Array)
      expect(entry_md.fetch('test:keywords')).to match_array(
        [
          { '@id' => base_url + '/vocabulary/keyword/' + keyword_1.id, '@type' => 'madek:Keyword' },
          { '@id' => base_url + '/vocabulary/keyword/' + keyword_2.id, '@type' => 'madek:Keyword' },
          {
            '@id' => base_url + '/vocabulary/keyword/' + keyword_with_external_uri.id,
            '@type' => 'madek:Keyword'
          }
        ]
      )

      expect(entry_md.fetch('test:people')).to be_an(Array)
      expect(entry_md.fetch('test:people')).to match_array(
        [
          { '@id' => base_url + '/people/' + person_1.id, '@type' => 'madek:Person' },
          { '@id' => base_url + '/people/' + person_2.id, '@type' => 'madek:Person' },
          {
            '@id' => base_url + '/people/' + person_with_external_uri.id, '@type' => 'madek:Person'
          }
        ]
      )

      expect(related_md).to be_an(Array)
      expect(related_md).to match_array(
        [
          {
            '@id' => base_url + '/vocabulary/keyword/' + keyword_1.id,
            '@type' => 'madek:Keyword',
            'rdfs:label' => keyword_1.term
          },
          {
            '@id' => base_url + '/vocabulary/keyword/' + keyword_2.id,
            '@type' => 'madek:Keyword',
            'rdfs:label' => keyword_2.term
          },
          {
            '@id' => base_url + '/vocabulary/keyword/' + keyword_with_external_uri.id,
            '@type' => 'madek:Keyword',
            'rdfs:label' => keyword_with_external_uri.term,
            'owl:sameAs' => [keyword_external_uri]
          },
          {
            '@id' => base_url + '/people/' + person_1.id,
            '@type' => 'madek:Person',
            'rdfs:label' => person_1.to_s
          },
          {
            '@id' => base_url + '/people/' + person_2.id,
            '@type' => 'madek:Person',
            'rdfs:label' => person_2.to_s
          },
          {
            '@id' => base_url + '/people/' + person_with_external_uri.id,
            '@type' => 'madek:Person',
            'rdfs:label' => person_with_external_uri.to_s,
            'owl:sameAs' => [person_external_uri]
          }
        ]
      )
    end
  end

  describe '#rdf_turtle' do
    let(:turtle) { subject.rdf_turtle }

    it 'contains correct prefix declarations' do
      expect(turtle.scan(/^@prefix \w+: <[^>]+> \./).size).to eq(6)
      expect_prefix(turtle, 'madek', base_url + '/ns#')
      expect_prefix(turtle, 'madek_core', base_url + '/vocabulary/madek_core:')
      expect_prefix(turtle, Keyword, base_url + '/vocabulary/keyword/')
      expect_prefix(turtle, 'rdfs', 'http://www.w3.org/2000/01/rdf-schema#')
      expect_prefix(turtle, 'owl', 'http://www.w3.org/2002/07/owl#')
      expect_prefix(turtle, 'test', base_url + '/vocabulary/test:')
    end

    it 'returns correct data' do
      expect(turtle).to match(
        Regexp.new("^<#{base_url}/entries/#{media_entry.id}> a madek:MediaEntry;$")
      )

      expect_triple(turtle, 'madek_core:title', title, 'madek:MetaDatum::Text')
      expect_triple(
        turtle,
        'test:textdate',
        meta_datum_text_date.string,
        'madek:MetaDatum::TextDate'
      )
      expect_triple(
        turtle,
        'test:keywords',
        %W[Keyword:#{keyword_1.id} Keyword:#{keyword_2.id} Keyword:#{keyword_with_external_uri.id}],
        'madek:MetaDatum::Text'
      )
      expect_triple(
        turtle,
        'test:people',
        %W[
          <#{base_url}/people/#{person_1.id}>
          <#{base_url}/people/#{person_2.id}>
          <#{base_url}/people/#{person_with_external_uri.id}>
        ]
      )
      expect_entity(
        turtle,
        "<#{base_url}/people/#{person_1.id}>",
        'madek:Person',
        "rdfs:label \"#{person_1.first_name} #{person_1.last_name} \\(#{person_1.pseudonym}\\)\""
      )
      expect_entity(
        turtle,
        "<#{base_url}/people/#{person_2.id}>",
        'madek:Person',
        "rdfs:label \"#{person_2.first_name} #{person_2.last_name} \\(#{person_2.pseudonym}\\)\""
      )
      rdfs_label =
        "#{person_with_external_uri.first_name} " \
          "#{person_with_external_uri.last_name} " \
          "\\(#{person_with_external_uri.pseudonym}\\)"
      expect_entity(
        turtle,
        "<#{base_url}/people/#{person_with_external_uri.id}>",
        'madek:Person',
        [
          "rdfs:label \"#{rdfs_label}\"",
          "owl:sameAs \"#{person_with_external_uri.external_uris.first}\""
        ]
      )
    end
  end

  describe '#rdf_xml' do
    let(:xml) { Nokogiri.XML(subject.rdf_xml) { |config| config.strict.noblanks } }

    it 'contains correct namespaces' do
      namespaces = xml.namespaces
      expect(namespaces.keys).to contain_exactly(
        'xmlns:madek',
        'xmlns:madek_core',
        'xmlns:Keyword',
        'xmlns:owl',
        'xmlns:rdf',
        'xmlns:rdfs',
        'xmlns:test'
      )
      expect(namespaces.fetch('xmlns:madek')).to eq(base_url + '/ns#')
      expect(namespaces.fetch('xmlns:madek_core')).to eq(base_url + '/vocabulary/madek_core:')
      expect(namespaces.fetch('xmlns:Keyword')).to eq(base_url + '/vocabulary/keyword/')
      expect(namespaces.fetch('xmlns:rdfs')).to eq('http://www.w3.org/2000/01/rdf-schema#')
      expect(namespaces.fetch('xmlns:owl')).to eq('http://www.w3.org/2002/07/owl#')
      expect(namespaces.fetch('xmlns:test')).to eq(base_url + '/vocabulary/test:')
    end

    it 'returns correct structure and data' do
      root = xml.root
      media_entry_node = xml.at_xpath('/rdf:RDF/madek:MediaEntry')

      expect(root.children.size).to eq(1)
      expect(media_entry_node).to be
      expect_attribute(
        media_entry_node,
        name: 'about', value: base_url + '/entries/' + media_entry.id
      )

      expect(media_entry_node.at_xpath('./madek_core:title')).to be
      expect_attribute(
        media_entry_node.at_xpath('./madek_core:title'),
        name: 'datatype', value: base_url + '/ns#MetaDatum::Text'
      )
      expect(media_entry_node.at_xpath('./madek_core:title').content).to eq(title)

      expect(media_entry_node.at_xpath('./test:textdate')).to be
      expect_attribute(
        media_entry_node.at_xpath('./test:textdate'),
        name: 'datatype', value: base_url + '/ns#MetaDatum::TextDate'
      )
      expect(media_entry_node.at_xpath('./test:textdate').content).to eq(
        meta_datum_text_date.string
      )

      expect(media_entry_node.xpath('./test:keywords').size).to eq(3)
      expect(media_entry_node.xpath('./test:keywords/madek:Keyword').size).to eq(3)

      expect_resource_node(media_entry_node, keyword_1)
      expect_resource_node(media_entry_node, keyword_2)
      expect_resource_node(media_entry_node, keyword_with_external_uri)

      expect_resource_node(media_entry_node, person_1)
      expect_resource_node(media_entry_node, person_2)
      expect_resource_node(media_entry_node, person_with_external_uri)
    end
  end
end

def expect_prefix(source, label, vocabulary_iri)
  expect(source).to match(Regexp.new("^@prefix #{label}: <#{vocabulary_iri}> \.$"))
end

def expect_triple(source, meta_key_id, value_or_array, iri = nil)
  value =
    if value_or_array.is_a?(Array)
      combinations = value_or_array.permutation.to_a.map { |a| a.join(',\n    ') }
      '(' + combinations.join('|') + ')'
    else
      '"' + value_or_array + '"\^\^' + iri
    end
  regexp = Regexp.new("^  #{meta_key_id} #{value}(;| .)$")
  expect(source).to match(regexp)
end

def expect_entity(source, prefixed_name_or_iri, type, *attributes)
  expect(source).to match(
    Regexp.new("^#{prefixed_name_or_iri} a #{type};\\n  #{attributes.join(';\n  ')} \\.")
  )
end

def expect_attribute(node, name:, value:, prefix: 'rdf')
  attribute =
    node.attribute_nodes.detect do |attr_node|
      attr_node.name == name && attr_node.namespace.prefix == prefix
    end
  expect(attribute).to be
  expect(attribute.value).to eq(value)
end

def resource_path(klass_name)
  case klass_name
  when 'Keyword'
    '/vocabulary/keyword/'
  when 'Person'
    '/people/'
  else
    raise "[#{klass_name}] class is not supported"
  end
end

def expect_resource_node(parent_node, resource)
  klass_name = resource.class.name
  plural = klass_name.tableize

  rdfs_label = parent_node.at_xpath(".//rdfs:label[contains(text(), '#{resource}')]")
  expect(rdfs_label).to be

  if resource.external_uris.present?
    owl_same_as_node = rdfs_label.next

    expect(owl_same_as_node).to be
    expect(owl_same_as_node.name).to eq('sameAs')
    expect(owl_same_as_node.namespace.prefix).to eq('owl')
    expect(owl_same_as_node.content).to eq(resource.external_uris.first)
  end

  resource_node = rdfs_label.parent
  expect(resource_node).to be
  expect(resource_node.name).to eq(klass_name)
  expect(resource_node.namespace.prefix).to eq('madek')
  expect_attribute(
    resource_node,
    name: 'about', value: base_url + resource_path(klass_name) + resource.id
  )

  meta_key_node = resource_node.parent
  expect(meta_key_node.name).to eq(plural)
  expect(meta_key_node.namespace.prefix).to eq('test')
end
