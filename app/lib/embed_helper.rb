# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/LineLength
module EmbedHelper
  extend ActiveSupport::Concern

  UI_DEFAULT_WIDTH  = Madek::Constants::Webapp::EMBED_UI_DEFAULT_WIDTH
  UI_DEFAULT_HEIGHT = Madek::Constants::Webapp::EMBED_UI_DEFAULT_HEIGHT
  UI_DEFAULT_HEIGHTS = Madek::Constants::Webapp::EMBED_UI_DEFAULT_HEIGHTS
  UI_MIN_WIDTH = Madek::Constants::Webapp::EMBED_UI_MIN_WIDTH
  UI_MIN_HEIGHT = Madek::Constants::Webapp::EMBED_UI_MIN_HEIGHT
  UI_EXTRA_HEIGHT = Madek::Constants::Webapp::EMBED_UI_EXTRA_HEIGHT

  def scale_preview_sizes(
    entry,
    ui_minwidth: UI_MIN_WIDTH, ui_minheight: UI_MIN_HEIGHT, ui_extraheight: UI_EXTRA_HEIGHT,
    maxwidth: nil, maxheight: nil
  )
    type = entry.media_type.to_sym
    default_width = UI_DEFAULT_WIDTH
    default_height = UI_DEFAULT_HEIGHTS[type] || UI_DEFAULT_HEIGHT

    case type
    when :video
      # we don't know size of source, but get from largest preview
      source_width = entry.media_file.previews[:videos].map(&:width).max
      source_height = entry.media_file.previews[:videos].map(&:height).max

      # TODO: use this when media_file.meta_data has a JSONb version in DB (perf)
      # when :image
      #   # try to get original image size from file metadata
      #   fmd = entry.media_file.instance_variable_get(:@app_resource).meta_data
      #   source_width = fmd['File:ImageWidth'] || fmd['PNG:ImageWidth']
      #   source_height = fmd['File:ImageHeight'] || fmd['PNG:ImageHeight']
    end
    source_width ||= default_width
    source_height ||= default_height - UI_EXTRA_HEIGHT

    # use optional params or from source – don't enlarge unless requested.
    max_width = maxwidth.nil? ? source_width : [maxwidth.to_i, source_width].min
    max_height = maxheight.nil? ? source_height + ui_extraheight : [maxheight.to_i, source_height + ui_extraheight].min
    max_height -= ui_extraheight
    scale = [max_width.to_f / source_width, max_height.to_f / source_height].min

    # dont go smaller than the UI supports
    {
      width: [(source_width * scale), ui_minwidth].max.to_i,
      height: [(source_height * scale), ui_minheight].max.to_i + ui_extraheight
    }
  end

end
