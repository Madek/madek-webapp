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
        related = { keywords: [], people: [] }
        resource_md = meta_data.map do |md|
          value =
            case md.class.name
            when 'MetaDatum::Text'
              { '@value': md.string, '@type': 'madek:MetaDatum::Text' }

            when 'MetaDatum::TextDate'
              { '@value': md.string, '@type': 'madek:MetaDatum::TextDate' }

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

            else
              fail 'not implemented! md type: ' + md.class
            end
          { md.meta_key_id => value }
        end.reduce({}, &:merge)

        @_meta_data_graph = {
          resource: resource_md,
          relateds: related.values.map { |arr| arr.uniq { |h| h.fetch(:@id) } }
        }
      end

      def vocabularies_map
        @_vocabularies_map ||= meta_data
          .uniq(:vocabulary_id).group_by(&:vocabulary).map(&:first)
          .sort_by(&:position)
          .map do |v|
            { v.id => full_url("/#{v.id}:") }
          end.reduce({}, &:merge)
      end

      def hardcoded_prefixes
        {
          madek: full_url('/ns#'),
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

      # temp
      def full_url(path)
        'https://medienarchiv.zhdk.ch' + path
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
