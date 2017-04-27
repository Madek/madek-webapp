# config
OLD_META_KEY = 'media_content:portrayed_object_country_code'
NEW_META_KEY = 'migrated:portrayed_object_country_code'
# NOTE: no https available :(
DATA_URL = 'http://download.geonames.org/export/dump/countryInfo.txt'
EXTERNAL_URL_BASE = 'http://geonames.org/countries'
LABEL_LANGUAGE = "de"
LABELS_FILE = "./node_modules/i18n-iso-countries/langs/#{LABEL_LANGUAGE}.json"

# get data
names_by_code = begin
  JSON.parse(File.read(LABELS_FILE))
rescue => e
  Rails.logger.warn e
  fail "Label Language not found! see "\
    "https://www.npmjs.com/package/i18n-iso-countries#supported-languages"
end

countries = `curl '#{DATA_URL}'`.chomp
  .split("\n")
  .reject { |line| line.start_with? '#' }
  .map {|line| line.split "\t" }
  .map {|fields| {code: fields[0], name: fields[4]}}

# prepare meta config
old_mkey = MetaKey.find_by(id: OLD_META_KEY)

unless old_mkey
  puts  "WARN: No MetaKey to migrate!"
  exit 1
end

vocab = Vocabulary.find_or_create_by!(id: NEW_META_KEY.split(':').first)
vocab.update_attributes!(
  label: NEW_META_KEY.split(':').first.humanize,
  enabled_for_public_use: false, enabled_for_public_view: false)

mkey_id = "#{vocab.id}:#{NEW_META_KEY.split(':').last}"

if MetaKey.find_by(id: mkey_id).present?
  puts "WARN: New Metakey already present! Already migrated?"
  exit 1
end

mkey = MetaKey.create!(id: mkey_id, vocabulary: vocab)

mkey.update_attributes!(
  old_mkey.attributes
    .except('id', 'vocabulary_id')
    .merge(
      meta_datum_object_type: 'MetaDatum::Keywords',
      admin_comment: \
        "[Migrated from '#{old_mkey.id}' on #{DateTime.now.utc.as_json}]" + \
        "\n" + (old_mkey.admin_comment || '')))

keyword_type = RdfClass.find_or_create_by!(
  id: 'Country',
  description: 'Country, identified by 2-letter code (ISO-3166)')

# add all countries as custom keywords
countries.each do |country|
  code = country[:code]
  uri = "#{EXTERNAL_URL_BASE}/#{code}/"
  name = names_by_code[code]
  flag = code.each_codepoint.map { |c| c + 127397 }.pack('U*') # unicode flag
  term = "#{code} - #{name}"
  description = "#{name} - #{code} - #{flag}"

  kw = Keyword.find_by(meta_key_id: mkey.id, external_uri: uri)
  kw ||= Keyword.create!(term: term, meta_key_id: mkey.id, external_uri: uri)
  kw.update_attributes!(rdf_class: keyword_type, description: description)
end

MetaDatum.where(meta_key_id: OLD_META_KEY).each do |meta_datum|
  # find the resource of the MD
  resource = meta_datum.media_entry || meta_datum.collection || meta_datum.filter_set

  # abort if there is already an MD for the NEW KEY
  next if resource.meta_data.where(meta_key_id: mkey.id).any?

  # find the Country-keyword for this Text,
  # or add it as new one (must be cleaned up manually)
  code = meta_datum.string
  uri = "#{EXTERNAL_URL_BASE}/#{code}/"
  keyword = Keyword.find_by(external_uri: uri, meta_key: mkey)
  unless keyword
    keyword = Keyword.find_or_create_by!(term: meta_datum.string, meta_key: mkey)
    keyword.update_attributes!(
      description: 'MADEK_SYSTEM_INVALID_ISO_COUNTRY_CODE')
  end

  # we need a 'creator' for new MD, but it might not exist in old MD.
  # find the responsible user for the resource and
  creator = meta_datum.created_by || resource.responsible_user

  # copy MetaDatum
  MetaDatum::Keywords.create_with_user!(
    creator,
    meta_datum.attributes
      .except('id', 'type', 'string')
      .merge(meta_key_id: mkey.id, value: keyword, created_by: creator))
end
