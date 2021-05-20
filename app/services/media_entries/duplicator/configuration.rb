class MediaEntries::Duplicator::Configuration
  DEFAULTS = {
    copy_meta_data: true,
    copy_permissions: true,
    copy_relations: true,
    copy_timestamps: false,
    move_custom_urls: false,
    remove_permissions_from_originator: false,
    annotate_as_new_version_of: false
  }.freeze

  def initialize(config = {})
    @config = config.symbolize_keys.reverse_merge(DEFAULTS)
    validate_config
  end

  def method_missing(config_key)
    config.fetch(config_key.to_sym)
  end

  private

  attr_reader :config

  def validate_config
    validate_keys
    validate_values
  end

  def validate_keys
    if (key = config.keys.detect { |k| DEFAULTS.keys.include?(k) == false })
      raise KeyError, "Configuration key #{key} is unsupported."
    end
  end

  def validate_values
    if (option = config.detect { |k, v| [true, false].include?(v) == false }&.first)
      raise TypeError, "Configuration option #{option} must have a boolean value."
    end
  end
end
