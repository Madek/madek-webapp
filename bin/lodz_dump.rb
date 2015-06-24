#!/usr/bin/env bundle exec rails runner

# dump all public media entries, with all relations as RDF
# call with:
# ```sh
# ssh root@test.madek.zhdk.ch
# su - madek
# cd madek_app
# rbenv-load
# export RAILS_ENV=production
# export RAILS_DUMP_LIMIT=100; time { bundle exec rails runner ./bin/lodz_dump.rb \
# > tmp/lodz_dump_n${RAILS_DUMP_LIMIT}.json ;}
# ```

# debug:
$stderr.puts 'VOCABS: ' + Vocabulary.all.map(&:id).join(', ')

# TODO: preview file url
LIMIT = ENV['RAILS_DUMP_LIMIT'] || 12
START_TIME = Time.now

# ---
# Q: what do we want to dump?
# A: all entries with 'public' permissions.
public_entries = MediaEntry.where(get_metadata_and_previews: true).limit(LIMIT)

# ---
# Q: what metadata do we want to dump?
# A: SUS says: just all meta keys from these vocabularies.
# Also, here is no "duplication", meaning in v2:
# every MetaKey has at most 1 MetaKeyDefinition in all of these Contexts combined
prod_vocabularies = [:media_content, :media_object, :copyright, :zhdk_bereich]
                        .flatten

# use those, or get them from the env if defined:
main_vocabularies = begin
                      JSON.parse(ENV['RAILS_DUMP_VOCS']).map(&:to_sym)
                    rescue
                      prod_vocabularies
                    end

# Select the MetaKeys:
meta_keys = main_vocabularies
                .map { |voc_id| MetaKey.where(vocabulary_id: voc_id) }.flatten

# sanity check: non-duplication-promise above
# (just check if the name after the `vocabulary:` is unique)
meta_key_ids = meta_keys.map(&:id)
fail 'does not compute!' unless meta_key_ids.length == meta_key_ids.uniq.length
# # proof this in v2:
# mkdefs_by_mkey = vocabularies
#   .map { |voc_id| MetaKeyDefinition.where(context_id: voc_id) }.flatten
#   .group_by {|d| d.meta_key.id}
# multiple_defs = mkdefs
#   .map {|mkey_id, mkdefs| [mkey_id, mkdefs] if mkdefs.length > 1}.compact
# multiple_defs.empty? # => true

# helpers:
def entry_for_graph(entry, vocabulary_ids)
  get = Presenters::MediaEntries::MediaEntryShow.new(entry, nil)
  {
    type: 'madek:MediaEntry',
    url: "/entries/#{entry.id}",
    created_at: entry.created_at,
    updated_at: entry.updated_at,
    meta_data: {
      'madek_core:responsible_user' => [get.responsible]
    }.merge(metadata_for_entry(get, vocabulary_ids) || {})
  }
end

def metadata_for_entry(entry, vocabulary_ids)
  # returns a simple hash `{ "MetaKey": "(Array of) Literal Value or Presenter" }`
  vocabulary_ids.map do |voc_id|
    dat = entry.meta_data.by_vocabulary[voc_id].try(:_meta_data)
    dat.map { |mdatum| mdatum_from_presenter(mdatum) } if dat.presence
  end.flatten.compact.reduce(&:merge)
end

def mdatum_from_presenter(meta_datum)
  if (values = meta_datum._values.presence)
    { meta_datum._key.uuid => values }
  end
end

def extract_and_transform_resource_values(meta_datum)
  values = meta_datum.second
  return nil unless values.first.is_a?(Presenter)
  type = 'madek:' + values.first.class.name.split('::').last.gsub(/Index/, '')
  {
    references: values.map(&:url),
    objects: values.map { |presenter| { type: type }.merge(presenter.dump) }
  }
end

# returns a combined graph of the Entries and related Resources:
def build_graph_from_entries(entries, vocabularies)
  # prepare the list of Entries:
  entries = entries.map do |entry|
    entry_for_graph(entry, vocabularies)
  end

  # map through all EntriesMetadata of all Entries, if value is a Resource:
  # add Resource to graph and replace value with a reference to it.
  related_resources = []
  graph = entries.map do |entry|
    entry[:meta_data] = entry[:meta_data].map do |meta_datum|
      if (resources = extract_and_transform_resource_values(meta_datum))
        related_resources = related_resources.concat(resources[:objects])
        meta_datum = [meta_datum.first, resources[:references]]
      end
      # unwrap single-item value arrays:
      meta_datum[1] = meta_datum[1].first if meta_datum[1].length == 1
      meta_datum
    end.to_h
    # un-nest meta_data properties
    entry.except(:meta_data).merge(entry[:meta_data])
  end

  # combine, remove duplicates, sort
  graph.concat(related_resources).uniq.sort_by do |node|
    node[:type] == 'madek:MediaEntry' ? '1' : node[:type] # put the entries first
  end
end

def vocabularies_for_context(vocabularies)
  meta_keys = vocabularies.map do |voc_id|
    meta_keys = Vocabulary.find_by(id: voc_id).try(:meta_keys).try(:flatten) || []
    unless meta_keys.presence
      $stderr.puts 'WARN: No meta_keys for: ' + voc_id.to_s
    end

    meta_keys.map do |meta_key|
      return unless meta_key.is_enabled_for_media_entries
      [meta_key.id, {
        'name' => meta_key.label,
        'description' => meta_key.description.presence,
        'hint' => meta_key.hint.presence,
        '@type' => get_metadatum_type(meta_key)
      }.compact]
    end.compact
  end

  meta_keys.compact.flatten(1).presence.try(:to_h).presence || {}
end

def get_metadatum_type(meta_key)
  plain_types = ['Text', 'TextDate']
  mk_class = meta_key.meta_datum_object_type.split('::').last
  # all "plain" values are strings, "reference values" have type '@id':
  plain_types.include?(mk_class) ? 'xsd:string' : '@id'
end

# main:
header = {
  '_about' => '[#LODZ] Dump of public entries, metadata and related resources.
      from http://medienarchiv.zhdk.ch.
      (Work in Progress)
     ',
  '_public_entries_count' => public_entries.count.to_s,
  '_date' => Time.now.utc.as_json
}

context = {
  # rename props
  'url' => '@id',
  'type' => '@type',
  'graph' => '@graph',
  # external vocabularies
  'xsd' => 'http://www.w3.org/2001/XMLSchema#',
  # base url
  '@base' => 'http://test.madek.zhdk.ch', # base url for resources
  # types ns
  'madek' => 'http://test.madek.zhdk.ch/ns/type/',
  # props from related resources:
  'term' => 'http://schema.org/name',
  'name' => 'http://schema.org/name',
  # main vocabularies
  'madek_core' => {
    '@id' => 'http://test.madek.zhdk.ch/ns/vocabulary/madek_core/' },
  'madek:core:preview_url' => {
    '@id' => 'http://schema.org/image',
    '@type' => '@id'
  },
  # 'media_content' => {
  #   '@id' => 'http://test.madek.zhdk.ch/ns/vocabulary/media_content/' },
  # 'media_object' => {
  #   '@id' => 'http://test.madek.zhdk.ch/ns/vocabulary/media_object/' },
  # 'zhdk_bereich' => {
  #   '@id' => 'http://test.madek.zhdk.ch/ns/vocabulary/zhdk_bereich/' },
  # 'copyright' => {
  #   '@id' => 'http://test.madek.zhdk.ch/ns/vocabulary/copyright/' }
}.merge(vocabularies_for_context(main_vocabularies))

output = header.merge(
  '@context' => context,
  'graph' =>    build_graph_from_entries(public_entries, main_vocabularies)
)

runtime = (Time.now - START_TIME).round.to_s

puts JSON.pretty_generate(output.merge('_runtime' => runtime))
