module EmbedHelper
  extend ActiveSupport::Concern

  UI_DEFAULT_WIDTH = Madek::Constants::Webapp::EMBED_UI_DEFAULT_WIDTH
  UI_MIN_WIDTH = Madek::Constants::Webapp::EMBED_UI_MIN_WIDTH
  UI_MIN_HEIGHT = Madek::Constants::Webapp::EMBED_UI_MIN_HEIGHT
  UI_DEFAULT_RATIO = Madek::Constants::Webapp::EMBED_UI_DEFAULT_RATIO
  EMBED_INTERNAL_HOST_WHITELIST = Madek::Constants::Webapp::
    EMBED_INTERNAL_HOST_WHITELIST

  def scale_preview_sizes(maxwidth: nil, ratio: nil)
    # support param of form "16:9"
    if ratio.is_a? String
      a, b = ratio.split(':')
      ratio = !b ? ratio.to_f : (a.to_i.to_f / b.to_i)
    end
    ratio = UI_DEFAULT_RATIO unless (ratio && ratio > 0)

    # use optional params, dont go smaller than the UI supports
    width = maxwidth
    width = UI_DEFAULT_WIDTH unless (width && width.to_i > 0)
    width = [width.to_i, UI_MIN_WIDTH].max
    height = [(width / ratio).floor, UI_MIN_HEIGHT].max

    { width: width, height: height }
  end

  private

  def embed_whitelisted?
    from_origin = request.env['HTTP_REFERER']
    return false unless from_origin
    EMBED_INTERNAL_HOST_WHITELIST
      .any? { |h| URI.join(h, '/') == URI.join(from_origin, '/') }
  end

end
