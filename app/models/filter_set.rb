# -*- encoding : utf-8 -*-
class FilterSet < MediaSet

  # NOTE provides alias for routes and used for sti type switcher
  def self.model_name
    MediaSet.model_name
  end

  # extending settings
  ACCEPTED_SETTINGS[:filter] = {:default => {}}

  def get_filter
    settings[:filter] || ACCEPTED_SETTINGS[:filter][:default]
  end

  def child_media_resources
    settings[:filter] ||= ACCEPTED_SETTINGS[:filter][:default]
    MediaResource.filter(nil, settings[:filter])
  end

  def get_media_file(user)
    nil
  end

end
