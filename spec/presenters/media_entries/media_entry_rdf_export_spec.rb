require 'spec_helper'

describe Presenters::MediaEntries::MediaEntryRdfExport, transact_check_or_seed_broken: true do
  before { truncate_tables }
  let(:base_url) { 'https://madek.example.org' }
  let(:user) { create :user }
  let(:title) { Faker::Artist.name }
  let(:media_entry) { create(:media_entry_with_title, responsible_user: user, title: title) }
  let(:vocabulary) { create(:vocabulary) }
  let!(:meta_datum_text_date) do
    create(:meta_datum_text_date, string: Time.current, media_entry: media_entry)
  end
  let!(:meta_datum_json) do
    create(:meta_datum_json, media_entry: media_entry)
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
  let!(:meta_key_roles) { create(:meta_key_roles) }
  let!(:meta_datum_roles) do
    create(:meta_datum_roles, media_entry: media_entry)
  end
  let(:meta_data_roles) { meta_datum_roles.meta_data_roles }
  subject { Presenters::MediaEntries::MediaEntryRdfExport.new(media_entry, user) }

  before { allow(Settings).to receive(:madek_external_base_url).and_return(base_url) }

  describe '#json_ld' do
    let(:json) { subject.json_ld }

    it 'returns correct JSON-LD' do
      expect(json.keys).to contain_exactly('@context', '@graph')
      expect(json.fetch('@context')).to be_a(Hash)
      expect(json.fetch('@graph')).to be_an(Array)
      write_json_file_to_disk('media_entry_rdf_export_spec.example.json', json)
    end

    it 'returns correct @context node' do
      # MATCH HASH:
      # compare whole hash, only interpolate strings if absolutely needed
      # (e.g. the base_url is fixed in this spec, so can stay fixed in the strings as well.)
      expect(json['@context']).to eq(
        '@base' => 'https://madek.example.org/',
        'madek' => 'https://madek.example.org/ns#',
        'madek_system' => 'https://madek.example.org/vocabulary/madek_system:',
        'Keyword' => 'https://madek.example.org/vocabulary/keyword/',
        'Role' => 'https://madek.example.org/roles/',
        'rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
        'owl' => 'http://www.w3.org/2002/07/owl#',
        'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        'madek_core' => 'https://madek.example.org/vocabulary/madek_core:',
        'madek_test' => 'https://madek.example.org/vocabulary/test:'
      )
    end

    it 'returns correct @graph node' do
      entry_md, *related_md = json.fetch('@graph')

      expect(entry_md).to be_a(Hash)

      # MATCH HASH, without sub-arrays!
      meta_keys_with_array_values = [
        'madek_test:keywords', 'madek_test:people',
        'madek_test:json', 'madek_' + meta_datum_roles.meta_key_id]

      expected_entry_md_graph = {
        '@id' => (base_url + '/entries/' + media_entry.id),
        '@type' => 'madek:MediaEntry',
        'madek_core:title' => { '@value' => title, '@type' => 'madek:Text' },
        'madek_test:textdate' => {
          '@value' => meta_datum_text_date.string, '@type' => 'madek:TextDate'
        },
        **meta_datum_roles.meta_data_roles.select(&:role_id).map do |md|
          ["Role:#{md.role_id}".to_sym, { '@id' => base_url + '/people/' + md.person_id }]
        end.to_h
      }

      expected_roles_graph = meta_datum_roles.meta_data_roles.select(&:role_id).map do |md|
          ["Role:#{md.role_id}".to_sym, { '@id' => base_url + '/people/' + md.person_id }]
      end.to_h

      expect(
        entry_md.except(*meta_keys_with_array_values)
      ).to eq({}.merge(expected_entry_md_graph).merge(expected_roles_graph).as_json)

      pending 'CHECK REST OF DATA!'

      expect(JSON.parse(entry_md.dig('test:json', '@value'))).to eq(meta_datum_json.json)
      expect(entry_md.dig('test:json', '@type')).to eq('madek:JSON')

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

      expect(entry_md.fetch(meta_datum_roles.meta_key_id)).to be_an(Array)
      expect(entry_md.fetch(meta_datum_roles.meta_key_id)).to match_array(
        [
          {
            '@type' => 'madek:::Roles',
            '@list' => [
              {
                '@id' => base_url + '/people/' + meta_data_roles[0].person_id,
                '@type' => 'madek:Person'
              },
              {
                '@id' => base_url + '/roles/' + meta_data_roles[0].role_id,
                '@type' => 'madek:Role'
              }
            ]
          },
          {
            '@type' => 'madek:MetaDatum::Roles',
            '@list' => [
              {
                '@id' => base_url + '/people/' + meta_data_roles[1].person_id,
                '@type' => 'madek:Person'
              },
              {
                '@id' => base_url + '/roles/' + meta_data_roles[1].role_id,
                '@type' => 'madek:Role'
              }
            ]
          },
          {
            '@type' => 'madek:MetaDatum::Roles',
            '@list' => [
              {
                '@id' => base_url + '/people/' + meta_data_roles[2].person_id,
                '@type' => 'madek:Person'
              },
              {
                '@id' => base_url + '/roles/' + meta_data_roles[2].role_id,
                '@type' => 'madek:Role'
              }
            ]
          },
          {
            '@type' => 'madek:MetaDatum::Roles',
            '@list' => [
              {
                '@id' => base_url + '/people/' + meta_data_roles[3].person_id,
                '@type' => 'madek:Person'
              }
            ]
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
          },
          {
            '@id' => base_url + '/people/' + meta_data_roles[0].person_id,
            '@type' => 'madek:Person',
            'rdfs:label' => meta_data_roles[0].person.to_s
          },
          {
            '@id' => base_url + '/roles/' + meta_data_roles[0].role_id,
            '@type' => 'madek:Role',
            'rdfs:label' => meta_data_roles[0].role.to_s
          },
          {
            '@id' => base_url + '/people/' + meta_data_roles[1].person_id,
            '@type' => 'madek:Person',
            'rdfs:label' => meta_data_roles[1].person.to_s
          },
          {
            '@id' => base_url + '/roles/' + meta_data_roles[1].role_id,
            '@type' => 'madek:Role',
            'rdfs:label' => meta_data_roles[1].role.to_s
          },
          {
            '@id' => base_url + '/people/' + meta_data_roles[2].person_id,
            '@type' => 'madek:Person',
            'rdfs:label' => meta_data_roles[2].person.to_s
          },
          {
            '@id' => base_url + '/roles/' + meta_data_roles[2].role_id,
            '@type' => 'madek:Role',
            'rdfs:label' => meta_data_roles[2].role.to_s
          },
          {
            '@id' => base_url + '/people/' + meta_data_roles[3].person_id,
            '@type' => 'madek:Person',
            'rdfs:label' => meta_data_roles[3].person.to_s
          }
        ]
      )
    end
  end

  describe '#rdf_turtle' do
    let(:turtle) { subject.rdf_turtle }

    it 'contains correct prefix declarations' do
      expect(turtle.scan(/^@prefix \w+: <[^>]+> \./).size).to eq(8)
      expect_prefix(turtle, 'madek', base_url + '/ns#')
      expect_prefix(turtle, 'madek_core', base_url + '/vocabulary/madek_core:')
      expect_prefix(turtle, Keyword, base_url + '/vocabulary/keyword/')
      expect_prefix(turtle, 'rdfs', 'http://www.w3.org/2000/01/rdf-schema#')
      expect_prefix(turtle, 'owl', 'http://www.w3.org/2002/07/owl#')
      expect_prefix(turtle, 'madek_test', base_url + '/vocabulary/test:')
    end

    pending 'returns correct data' do
      expect(turtle).to match(
        Regexp.new("^<#{base_url}/entries/#{media_entry.id}> a madek:MediaEntry;$")
      )

      expect_triple(turtle, 'madek_core:title', title, 'madek:Text')
      expect_triple(
        turtle,
        'test:textdate',
        meta_datum_text_date.string,
        'madek:TextDate'
      )
      # TODO
      # expect_triple(
      #   turtle,
      #   'test:json',
      #   %(\\{\\"seq\\":[1,2,null],\\"zero_point\\":-273.15,\\"some_boolean\\":true\\}),
      #   'madek:JSONText'
      # )
      expect_triple(
        turtle,
        'test:keywords',
        %W(Keyword:#{keyword_1.id} Keyword:#{keyword_2.id} Keyword:#{keyword_with_external_uri.id}),
        'madek:Text'
      )
      expect_triple(
        turtle,
        'test:people',
        %W(
          <#{base_url}/people/#{person_1.id}>
          <#{base_url}/people/#{person_2.id}>
          <#{base_url}/people/#{person_with_external_uri.id}>
        )
      )
      expect_triple(
        turtle,
        meta_datum_roles.meta_key_id,
        [
          "\\(<#{base_url}/people/#{meta_data_roles[0].person_id}> "\
          "<#{base_url}/roles/#{meta_data_roles[0].role_id}>\\)",
          "\\(<#{base_url}/people/#{meta_data_roles[1].person_id}> "\
          "<#{base_url}/roles/#{meta_data_roles[1].role_id}>\\)",
          "\\(<#{base_url}/people/#{meta_data_roles[2].person_id}> "\
          "<#{base_url}/roles/#{meta_data_roles[2].role_id}>\\)",
          "\\(<#{base_url}/people/#{meta_data_roles[3].person_id}>\\)"
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
      expect_entity(
        turtle,
        "<#{base_url}/people/#{meta_data_roles[0].person_id}>",
        'madek:Person',
        rdfs_label_for_person(meta_data_roles[0].person)
      )
      expect_entity(
        turtle,
        "<#{base_url}/roles/#{meta_data_roles[0].role_id}>",
        'madek:Role',
        "rdfs:label \"#{meta_data_roles[0].role}\""
      )
      expect_entity(
        turtle,
        "<#{base_url}/people/#{meta_data_roles[1].person_id}>",
        'madek:Person',
        rdfs_label_for_person(meta_data_roles[1].person)
      )
      expect_entity(
        turtle,
        "<#{base_url}/roles/#{meta_data_roles[1].role_id}>",
        'madek:Role',
        "rdfs:label \"#{meta_data_roles[1].role}\""
      )
      expect_entity(
        turtle,
        "<#{base_url}/people/#{meta_data_roles[2].person_id}>",
        'madek:Person',
        rdfs_label_for_person(meta_data_roles[2].person)
      )
      expect_entity(
        turtle,
        "<#{base_url}/roles/#{meta_data_roles[2].role_id}>",
        'madek:Role',
        "rdfs:label \"#{meta_data_roles[2].role}\""
      )
      expect_entity(
        turtle,
        "<#{base_url}/people/#{meta_data_roles[3].person_id}>",
        'madek:Person',
        rdfs_label_for_person(meta_data_roles[3].person)
      )
    end
  end

  describe '#rdf_xml' do
    let(:xml) { Nokogiri.XML(subject.rdf_xml) { |config| config.strict.noblanks } }

    it 'contains correct namespaces' do
      expect(xml.namespaces).to eq(
        'xmlns:madek' => 'https://madek.example.org/ns#',
        'xmlns:madek_core' => 'https://madek.example.org/vocabulary/madek_core:',
        'xmlns:Keyword' => 'https://madek.example.org/vocabulary/keyword/',
        'xmlns:Role' => 'https://madek.example.org/roles/',
        'xmlns:rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        'xmlns:rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
        'xmlns:owl' => 'http://www.w3.org/2002/07/owl#',
        'xmlns:madek_test' => 'https://madek.example.org/vocabulary/test:'
      )
    end

    pending 'returns correct structure and data' do
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

      expect(media_entry_node.at_xpath('./test:json')).to be
      expect_attribute(
        media_entry_node.at_xpath('./test:json'),
        name: 'datatype', value: base_url + '/ns#MetaDatum::JSON'
      )
      expect(JSON.parse(media_entry_node.at_xpath('./test:json').content)).to eq(
        meta_datum_json.json
      )

      expect(media_entry_node.xpath('./test:keywords').size).to eq(3)
      expect(media_entry_node.xpath('./test:keywords/madek:Keyword').size).to eq(3)

      expect_resource_node(media_entry_node, keyword_1)
      expect_resource_node(media_entry_node, keyword_2)
      expect_resource_node(media_entry_node, keyword_with_external_uri)

      expect_resource_node(media_entry_node, person_1)
      expect_resource_node(media_entry_node, person_2)
      expect_resource_node(media_entry_node, person_with_external_uri)

      meta_key_id = meta_datum_roles.meta_key_id.split(':').second
      expect_resource_node(
        media_entry_node,
        meta_data_roles[0].person,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[0].role,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[1].person,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[1].role,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[2].person,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[2].role,
        meta_key_id: meta_key_id
      )
      expect_resource_node(
        media_entry_node,
        meta_data_roles[3].person,
        meta_key_id: meta_key_id
      )
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

def rdfs_label_for_person(person)
  "rdfs:label \"#{person.first_name} #{person.last_name} \\(#{person.pseudonym}\\)\""
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
  when 'Role'
    '/roles/'
  else
    raise "[#{klass_name}] class is not supported"
  end
end

def expect_resource_node(parent_node, resource, meta_key_id: nil)
  klass_name = resource.class.name
  meta_key_id ||= klass_name.tableize

  rdfs_label = parent_node.at_xpath(".//rdfs:label[contains(text(), '#{resource}')]")
  expect(rdfs_label).to be

  if resource.respond_to?(:external_uris) && resource.external_uris.present?
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
  expect(meta_key_node.name).to eq(meta_key_id)
  expect(meta_key_node.namespace.prefix).to eq('test')
end

def write_json_file_to_disk(name, data)
  dir = Rails.root.join('tmp', 'spec_artefacts')
  FileUtils.mkdir_p(dir)
  path = dir.join(name)
  File.write(path, JSON.pretty_generate(data))
end
