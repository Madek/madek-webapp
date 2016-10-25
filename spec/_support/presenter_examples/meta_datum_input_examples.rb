#!/usr/bin/env bundle exec rails runner --sandbox

# examples for various MetaDatum inputs,
# as full Presenter "dumps" (in YAML format) (to stdout)

# uses mixture of prod data and fake examples
# (should use personas, but that fails atm)

# rubocop:disable Metrics/MethodLength
module Examples

  def core_keywords_without_existing_values
    meta_key = MetaKey.find('madek_core:keywords')
    {
      description: "\
        Core Keywords, no value | #{meta_key.id}
        extensible, keyword_count: #{keyword_count(meta_key)}
      ",
      props: {
        get: Presenters::MetaData::MetaDatumEdit.new(
          MetaDatum::Keywords.new(meta_key: meta_key),
          current_user)
      }
    }
  end

  def core_keywords_with_existing_values
    meta_key = MetaKey.find('madek_core:keywords')
    values = [Keyword.find_or_create_by!(meta_key: meta_key, term: 'Kunst')]
    {
      description: "\
        Core Keywords, with existing value | #{meta_key.id}
        extensible, keyword_count: #{keyword_count(meta_key)}
      ",
      props: {
        get: Presenters::MetaData::MetaDatumEdit.new(
          MetaDatum::Keywords.new(meta_key: meta_key, keywords: values),
          current_user)
      }
    }
  end

  def keywords_fresh
    vocab = Vocabulary.find_or_create_by(id: 'example')
    vocab.save!
    meta_key = MetaKey.create(
      id: 'example:keywords_fresh',
      meta_datum_object_type: 'MetaDatum::Keywords',
      vocabulary: vocab, is_enabled_for_media_entries: true,
      is_extensible_list: true
    )
    meta_key.save!
    {
      description: "\
        Keywords, with no keywords | #{meta_key.id}
        extensible, keyword_count: #{keyword_count(meta_key)}
        Autocomplete will never have any results
      ",
      props: {
        get: Presenters::MetaData::MetaDatumEdit.new(
          MetaDatum::Keywords.new(meta_key: meta_key), current_user)
      }
    }
  end

  def keywords_fixed_few
    vocab = Vocabulary.find_or_create_by(id: 'example')
    vocab.save!
    meta_key = MetaKey.create(
      id: 'example:keywords_fixed_few',
      meta_datum_object_type: 'MetaDatum::Keywords',
      vocabulary: vocab, is_enabled_for_media_entries: true,
      is_extensible_list: false
    )
    meta_key.save!
    12.times.map { |n| (n + 65).chr } # letters A, B, C, …, L
        .map { |term| Keyword.find_or_create_by!(term: term, meta_key: meta_key) }
        .each(&:save!)
    value_keywords = ['A', 'E', 'I']
                      .map { |c| Keyword.find_by!(term: c, meta_key: meta_key) }
    meta_datum = MetaDatum::Keywords.new(
      meta_key: meta_key, keywords: value_keywords)
    {
      description: "\
        Keyword, fixed with few keywords  | #{meta_key.id}
        with values, non-extensible, keyword_count: #{keyword_count(meta_key)}
        Checkboxes instead of Autocomplete
      ",
      props: {
        get: Presenters::MetaData::MetaDatumEdit.new(meta_datum, current_user)
      }
    }
  end

  def keywords_fixed_many
    vocab = Vocabulary.find_or_create_by(id: 'example')
    vocab.save!
    meta_key = MetaKey.create(
      id: 'example:keywords_fixed_many',
      meta_datum_object_type: 'MetaDatum::Keywords',
      vocabulary: vocab, is_enabled_for_media_entries: true,
      is_extensible_list: false
    )
    meta_key.save!
    26.times.map { |n| (n + 65).chr } # letters A, B, C, …, Z
        .map { |term| Keyword.find_or_create_by!(term: term, meta_key: meta_key) }
        .each(&:save!)
    value_keywords = ['A', 'E', 'I']
      .map { |c| Keyword.find_by!(term: c, meta_key: meta_key) }
    meta_datum = MetaDatum::Keywords.new(
      meta_key: meta_key, keywords: value_keywords)
    {
      description: "\
        Keyword, fixed with more than 16 keywords  | #{meta_key.id}
        with values, non-extensible, keyword_count: #{keyword_count(meta_key)}
        Autocomplete with up to 50 pre-filled values, shown without typing
        NOTE: in styleguide search won't work because the MetaKey doensnt' exist.
      ",
      props: {
        get: Presenters::MetaData::MetaDatumEdit.new(meta_datum, current_user)
      }
    }
  end

end

# helpers
def current_user
  User.find_by!(login: 'malbrech')
end

def keyword_count(meta_key)
  Keyword.where(meta_key: meta_key).count
end

# main
def dump_examples
  # needs to write to the DB to create example entities,
  # so run it in transaction which is aborted at the end.
  result = nil
  ActiveRecord::Base.transaction do
    module_ = Examples
    # "dump" module methods, then presenters in props
    result = module_.instance_methods
      .map { |method| { name: method }.merge(self.extend(module_).send(method)) }
      .map do |h|
        h.merge(
          description: h[:description].strip_heredoc,
          props: h[:props].merge(get: h[:props][:get].dump))
      end
    raise ActiveRecord::Rollback
  end
  result
end

# sanity check
fail "RAILS_ENV != 'development'" if Rails.env != 'development'

puts({ examples: dump_examples }.as_json.to_yaml)
