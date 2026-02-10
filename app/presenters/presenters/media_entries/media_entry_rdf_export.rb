# DOCS:
# * https://w3c.github.io/json-ld-syntax/
# * http://ruby-rdf.github.io/json-ld/
# * https://www.rubydoc.info/github/ruby-rdf/rdf/frames
#
# TOOLS:
# * https://json-ld.org/playground/

META_KEY_TYPE = 'madek:MetaKey'.freeze
MD_ROLE_TYPE = 'madek:Role'.freeze
MD_JSON_TYPE = 'madek:JSONText'.freeze
RDF_PROPERTY_TYPE = 'rdf:Property'.freeze
# MD_JSON_TYPE = 'rdf:JSON' # not stable yet

# rubocop:disable Metrics/ClassLength
module Presenters
  module MediaEntries
    class MediaEntryRdfExport < Presenters::Shared::AppResourceWithUser
      include Presenters::Shared::Modules::VocabularyConfig

      def json_ld
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
          '@graph': [entry_md, meta_data_graph[:relateds], hardcoded_relations].flatten
        }
      end

      def meta_data_graph
        return @_meta_data_graph if @_meta_data_graph
        related = { meta_keys: [], keywords: [], people: [], roles: [] }
        resource_md = meta_data.map do |md|
          value_node =
            case md.class.name
            when 'MetaDatum::Text'
              val = { '@value': md.string, '@type': 'madek:Text' }
              { cid_meta_key(md.meta_key) => val }

            when 'MetaDatum::TextDate'
              val = { '@value': md.string, '@type': 'madek:TextDate' }
              { cid_meta_key(md.meta_key) => val }

            when 'MetaDatum::JSON'
              val = { '@value' => md.json.to_json, '@type' => MD_JSON_TYPE }
              { cid_meta_key(md.meta_key) => val }

            when 'MetaDatum::Keywords'
              md.keywords.map do |k|
                val = {
                  '@id': full_url("/vocabulary/keyword/#{k.id}")
                }
                related[:keywords].push(val.merge(
                  '@type': 'madek:Keyword',
                  'rdfs:label': k.to_s,
                  "owl:sameAs": k.external_uris.presence
                ).compact)
                { cid_meta_key(md.meta_key) => val }
              end

            when 'MetaDatum::People'
              if !md.meta_key.can_have_roles?
                md.people.map do |p|
                  val = { '@id': iri_person(p) }
                  related[:people].push(map_person(p))
                  { cid_meta_key(md.meta_key) => val }
                end
              else
                # NOTE: Roles map to Properties themselves!
                md.meta_data_people.map do |mdr|
                  val = { '@id': iri_person(mdr.person) }

                  related[:people].push(map_person(mdr.person))

                  if !mdr.role
                    { cid_meta_key(md.meta_key) => val }
                  else
                    related[:roles].push(
                      '@id': iri_role(mdr.role),
                      '@type': MD_ROLE_TYPE,
                      'rdfs:subPropertyOf': iri_meta_key(md.meta_key)
                    )
                    { iri_role(mdr.role) => val }
                  end
                end
              end

            else
              fail 'not implemented! md type: ' + md.class
            end

          # also add the MetaKey as a property, so the labels are included for the consumer
          meta_key = md.meta_key
          related[:meta_keys].push(
            '@type': META_KEY_TYPE,
            '@id': cid_meta_key(meta_key),
            'rdfs:label': map_languages(meta_key.labels),
            'rdfs:comment': map_languages(meta_key.descriptions)
          )
          value_node
        end
        # binding.pry
        resource_md = resource_md.flatten.compact.reduce({}, &:merge)

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
            cid = v.id == 'madek_core' ? v.id : "madek_#{v.id}"
            { cid => full_url("/vocabulary/#{v.id}:") }
          end
          .reduce({}, &:merge)
      end

      def hardcoded_prefixes
        {
          madek: full_url('/ns#'),
          madek_system: full_url('/vocabulary/madek_system:'),
          Keyword: full_url('/vocabulary/keyword/'),
          Role: full_url('/roles/'),
          rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
          rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
          owl: 'http://www.w3.org/2002/07/owl#'
        }
      end

      def hardcoded_relations
        [
          # {'@id': MD_JSON_TYPE, '@type': 'rdf:JSON'}, # not stable yet
          unless META_KEY_TYPE == RDF_PROPERTY_TYPE
             { '@id': META_KEY_TYPE, '@type': RDF_PROPERTY_TYPE }
          end,
          unless MD_ROLE_TYPE == RDF_PROPERTY_TYPE
             { '@id': MD_ROLE_TYPE, '@type': RDF_PROPERTY_TYPE }
          end
        ].compact
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
        _notes = {
          publisher: -> { 'TODO: add string from new system setting' },
          identifier: -> { 'TODO: add own URL (full, absolute, UUID-based)' },
          resource_type: -> { 'TODO: add media type (audio/video/doc/other)' },
          relation: lambda do
            <<~TEXT
              TODO: add relations
              - parent set(s)
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

      def full_url(path)
        URI.parse(external_base_url).merge(path).to_s
      end

      def iri_meta_key(mk)
        full_url("/vocabulary/#{mk.id}")
      end

      def cid_meta_key(mk)
        if mk.id.split(':')[0] == 'madek_core'
          mk.id
        else
          "madek_#{mk.id}"
        end
      end

      def iri_person(p)
        full_url("/people/#{p.id}")
      end

      def iri_role(r)
        # use prefix because its used as a property
        "Role:#{r.id}"
      end

      def map_person(p)
        {
          '@type': 'madek:Person',
          '@id': iri_person(p),
          'rdfs:label': p.to_s,
          'owl:sameAs': p.external_uris.presence
        }.compact
      end

      def map_languages(strings)
        strings
          .map { |l, v| { '@language': l, '@value': v } }
          .presence
      end

      def external_base_url
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
