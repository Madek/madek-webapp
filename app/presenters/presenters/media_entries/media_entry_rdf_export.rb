# DOCS:
# * https://w3c.github.io/json-ld-syntax/
# * http://ruby-rdf.github.io/json-ld/
# * https://www.rubydoc.info/github/ruby-rdf/rdf/frames
#
# TOOLS:
# * https://json-ld.org/playground/

# TODO: …
# - support Roles!
# - check if owl:sameAs is correct?
# - test with data consumers!

module Presenters
  module MediaEntries
    class MediaEntryRdfExport < Presenters::Shared::AppResourceWithUser
      include Presenters::Shared::Modules::VocabularyConfig

      def json_ld
        # JSON::LD::API.compact(json_ld_graph, json_ld_graph["@context"])
        json_ld_graph.as_json
      end

      def rdf_turtle
        dump_rdf(json_ld_graph, :ttl)
      end

      def rdf_xml
        dump_rdf(json_ld_graph, :rdfxml)
      end

      private

      def json_ld_graph
        return @_json_ld_graph if @_json_ld_graph

        context = { '@base': full_url('/') }
          .merge(hardcoded_prefixes)
          .merge(vocabularies_map)

        entry_md = {
          '@id': full_url("/entries/#{@app_resource.id}"),
          '@type': 'madek:MediaEntry'
        }.merge(meta_data_graph[:resource])

        @_json_ld_graph ||= \
        {
          '@context': context,
          '@graph': [entry_md, meta_data_graph[:relateds]].flatten
        }
      end

      def meta_data_graph
        return @_meta_data_graph if @_meta_data_graph
        related = { keywords: [], people: [], roles: [] }
        resource_md = meta_data.map do |md|
          value =
            case md.class.name
            when 'MetaDatum::Text'
              { '@value': md.string, '@type': 'madek:MetaDatum::Text' }

            when 'MetaDatum::TextDate'
              { '@value': md.string, '@type': 'madek:MetaDatum::TextDate' }

            when 'MetaDatum::JSON'
              { '@value' => md.json.to_json, '@type' => 'madek:MetaDatum::JSON' }

            when 'MetaDatum::Keywords'
              md.keywords.map do |k|
                node = {
                  '@id': full_url("/vocabulary/keyword/#{k.id}"),
                  '@type': 'madek:Keyword'
                }
                related[:keywords].push(node.merge(
                  'rdfs:label': k.to_s,
                  # TODO: include those props
                  # _rdf_class: k.rdf_class,
                  "owl:sameAs": k.external_uris.presence
                ).compact)
                node
              end

            when 'MetaDatum::People'
              md.people.map do |p|
                node = {
                  '@id': full_url("/people/#{p.id}"),
                  '@type': 'madek:Person'
                }
                related[:people].push(node.merge(
                  'rdfs:label': p.to_s,
                  'owl:sameAs': p.external_uris.presence
                ).compact)
                node
              end

            when 'MetaDatum::Roles'
              md.meta_data_roles.map do |mdr|
                person_node = {
                  '@id': full_url("/people/#{mdr.person_id}"),
                  '@type': 'madek:Person'
                }
                role_node = mdr.role ? {
                  '@id': full_url("/roles/#{mdr.role_id}"),
                  '@type': 'madek:Role'
                } : nil
                node = {
                  '@type': 'madek:MetaDatum::Roles',
                  '@list': [person_node, role_node].compact
                }
                related[:roles].concat(
                  [
                    person_node.merge('rdfs:label': mdr.person.to_s),
                    role_node&.merge('rdfs:label': mdr.role.to_s)
                  ].compact
                )
                node
              end

            else
              fail 'not implemented! md type: ' + md.class
            end
          { md.meta_key_id => value }
        end.reduce({}, &:merge)

        systemd_md = system_vocabulary_meta_data.map do |key, md|
          value = md.call
          values = (value.is_a?(Array) ? value : [value]).map do |val|
            { '@value': val.to_s, '@type': 'madek:MetaDatum::Text' }
          end
          ["madek_system:#{key}", values]
        end.to_h

        @_meta_data_graph = {
          resource: resource_md.merge(systemd_md),
          relateds: related.values.map { |arr| arr.uniq { |h| h.fetch(:@id) } }
        }
      end

      def vocabularies_map
        @_vocabularies_map ||= meta_data
          .uniq(&:vocabulary)
          .group_by(&:vocabulary)
          .map(&:first)
          .sort_by(&:position)
          .map do |v|
            { v.id => full_url("/vocabulary/#{v.id}:") }
          end
          .reduce({}, &:merge)
      end

      def hardcoded_prefixes
        {
          madek: full_url('/ns#'),
          madek_system: full_url("/vocabulary/madek_system:"),
          Keyword: full_url('/vocabulary/keyword/'),
          rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
          owl: 'http://www.w3.org/2002/07/owl#'
        }
      end

      def dump_rdf(data, format)
        prefixes = {}.merge(hardcoded_prefixes).merge(vocabularies_map).as_json
        rdf_graph = RDF::Graph.new << JSON::LD::API.toRdf(data.as_json)
        rdf_graph.validate!
        rdf_graph.dump(format, prefixes: prefixes)
      end

      def system_vocabulary_meta_data
        # not a regular Vocab/MetaData, but combines system-provided data point in same format
        # for consistent export.

        # keys of this hash are handled like MetaKeys of id `madek_system:${key}`.
        {
          publisher: -> { 'TODO: add string from new system setting' },
          identifier: -> { 'TODO: add own URL (full, absolute, UUID-based)' },
          resource_type: -> { 'TODO: add media type (audio/video/doc/other)' },
          relation: lambda do
            <<~TEXT
              TODO: add relations
              - parent set(s) or "top level set" from workflow
                {relationType: 'IsPartOf', relatedIdentifierType: 'URL'}
              - new version:
                {relationType: 'IsNewVersionOf', relatedIdentifierType: 'URL'}
              - PIDs:
                {relationType: 'IsIdenticalTo', relatedIdentifierType: 'DOI'}

              for controlled value see https://schema.datacite.org/meta/kernel-4.3/doc/DataCite-MetadataKernel_v4.3.pdf
            TEXT
          end,
          alternateIdentifier: lambda do
            <<~TEXT
              TODO: add "own URL" in same format as 'relation':
              {alternateIdentifierType: 'IsIdenticalTo', relatedIdentifierType: 'DOI'}
            TEXT
          end,
          format: -> { 'TODO: add technical format of the resource (only Entries!)' }
        }

        # TMP: dont return the notes…
        {}
      end

      # temp
      def full_url(path)
        URI.parse(external_base_url).merge(path).to_s
      end

      def external_base_url
        # binding.pry
        @_external_base_url ||= Settings.madek_external_base_url
      end

      def meta_data
        @_meta_data ||= fetch_visible_meta_data
      end

      # NOTE: helpers below from Presenters::MetaData::MetaDataShow et. al.

      def fetch_visible_meta_data
        # NOTE: don't filter by enabled to no hide existing data!
        #       .where(is_enabled_for_media_entries: true)
        @app_resource
          .meta_data
          .joins(:vocabulary)
          .where(vocabularies: { id: visible_vocabularies_for_user.map(&:id) })
      end

      def visible_vocabularies_for_user
        @visible_vocabularies_for_user ||=
          auth_policy_scope(@user, Vocabulary.all)
            .sort_by
      end
    end
  end
end
