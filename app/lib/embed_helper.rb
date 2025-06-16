module EmbedHelper
  extend ActiveSupport::Concern

  UI_DEFAULT_WIDTH = Madek::Constants::Webapp::EMBED_UI_DEFAULT_WIDTH
  UI_MIN_WIDTH = Madek::Constants::Webapp::EMBED_UI_MIN_WIDTH
  UI_MIN_HEIGHT = Madek::Constants::Webapp::EMBED_UI_MIN_HEIGHT
  UI_DEFAULT_RATIO = Madek::Constants::Webapp::EMBED_UI_DEFAULT_RATIO
  IMAGE_CAPTION_HEIGHT = Madek::Constants::Webapp::EMBED_UI_IMAGE_CAPTION_HEIGHT

  def get_iframe_size_for_audio_video(maxwidth: nil, ratio: nil)
    # support param of form "16:9"
    if ratio.is_a? String
      ratio = parse_ratio(ratio)
    end
    ratio = UI_DEFAULT_RATIO unless (ratio && ratio > 0)

    # use optional params, dont go smaller than the UI supports
    width = maxwidth
    width = UI_DEFAULT_WIDTH unless (width && width.to_i > 0)
    width = [width.to_i, UI_MIN_WIDTH].max
    height = [(width / ratio).floor, UI_MIN_HEIGHT].max

    { width: width, height: height }
  end

  def get_iframe_size_for_image(maxwidth: nil, maxheight: nil, media_size: nil)
    # Assume a media size when the actual size is unknown (images uploaded with Madek v3 before 3.35.0) 
    media_size = media_size || Madek::Constants::THUMBNAILS[:x_large]
    ratio = media_size[:width].to_f / media_size[:height].to_f
    
    # Width according to consumer-defined maxsize parameter, or default
    width = maxwidth && maxwidth.to_i > 0 ? maxwidth.to_i : UI_DEFAULT_WIDTH

    # Landscape: Prevent left/right gutter
    if ratio >= 1
      width = [width, media_size[:width]].min
    end

    # Calculate proportional height plus caption height
    height = (width.to_f / ratio).round + IMAGE_CAPTION_HEIGHT

    # Fulfill consumer-defined maxheight
    if maxheight.present? && maxheight.to_i > 0 && height > maxheight.to_i
      height = maxheight.to_i
    end

    # Portrait: Prevent top/bottom gutter
    if ratio < 1 
      height = [height, media_size[:height] + IMAGE_CAPTION_HEIGHT].min
    end

    { width: width, height: height }
  end

  def get_media_size_of(media_entry)
    if media_entry.media_file.width.nil?
      # Dimensions are unknown for all non-images, but also for images uploaded in Madek version v3 (but before 3.35.0)
      return nil
    else
      # Get dimensions of x_large preview (which is the image source in the output)
      x_large_preview = media_entry.media_file.previews.find { |x| x.thumbnail == "x_large" && x.width.present? }
      if x_large_preview.nil?
        return nil
      end
      { width: x_large_preview.width, height: x_large_preview.height}
    end
  end

  private

  # convert string of form "16:9" to float
  def parse_ratio(ratio)
    a, b = ratio.split(':')
    !b ? ratio.to_f : (a.to_i.to_f / b.to_i)
  end

  def referer_info
    u = URI.parse(request.env['HTTP_REFERER'])
    # NOTE: we can only rely on "host" in practice
    #       (see Referrer-Policy HTTP Headers and related browser heuristics)
    { host: u.host }
  rescue
    nil
  end

end
