# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/LineLength
class OembedController < ApplicationController

  include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

  OEMBED_VERSION = '1.0'.freeze # should never change, spec is frozen
  API_ENDPOINT = '/oembed'.freeze
  # naming like controllers, only is supposed to work for "resourcefull routes"!
  SUPPORTED_RESOURCES = ['media_entries'].freeze
  SUPPORTED_MEDIA = ['video'].freeze
  UI_EXTRA_HEIGHT = 55 # pixels (added by tile on bottom)

  # # if a config (according to oEmbed spec) needed to be built, it would be like:
  # OEMBED_CONFIG = [{ # pairs of supported URL schemes and their API endpoint
  #     url_scheme: 'https://madek.example.com/entries/*',
  #     api_endpoint: 'https://madek.example.com/oembed'
  # }]

  def show
    # NOTE: this *only* returns JSON, no matter what was requested!
    #       therefore all errors are catched to not trigger rails default behaviour

    # NOTE: `url` accepts anything that Rails recognizes, for simplicity
    #       (so giving the "correct" external hostname is not strcitly needed)

    # disregard any auth (only 'public' resources are served!)
    skip_authorization
    current_user = nil

    # params?
    params = begin
      oembed_params
    rescue => err
      return error_response(err, 422)
    end
    unless params[:format] == 'json'
      return error_response('unsupported `format`!', 501)
    end

    # resource?
    resource = begin
      route_params = Rails.application.routes.recognize_path(params[:url])
      unless SUPPORTED_RESOURCES.include?(route_params[:controller])
        return error_response('invalid `url`!', 422)
      end
      resource_class = route_params[:controller].classify.constantize
      resource_class.find(route_params[:id])
    rescue ActionController::RoutingError => err
      return error_response(err, 422)
    rescue ActiveRecord::RecordNotFound => err
      return error_response(err, 404)
    rescue => err
      return error_response(err, 500)
    end

    # public?
    unless resource.get_metadata_and_previews
      return render(json: { error: 'non-public Resource!' }, status: 401)
    end

    # correct media type?
    unless SUPPORTED_MEDIA.include?(resource.try(:media_file).try(:media_type))
      return render(json: { error: 'unsupported media_type!' }, status: 501)
    end

    presenter = presenter_by_class(resource_class).new(resource, current_user)
    render(json: oembed_response(resource, presenter, params))
  end

  private

  # NOTE: only 'video' type supported
  def oembed_response(resource, presenter, params)
    # NOTE: MUST set fixed sizes on iframe, so we need to proportionally scale it!
    #      'minwidth' and 'minheight' is what the UI supports
    #       we respect it but don't return an error (would be correct but no fun)
    scaled = scale_preview_sizes(
      presenter,
      ui_minwidth: 320, ui_minheight: 140, ui_extraheight: UI_EXTRA_HEIGHT,
      maxwidth: params[:maxwidth], maxheight: params[:maxheight])

    target_url = absolute_url(
      embedded_media_entry_path(
        resource.id, maxheight: scaled[:height], maxwidth: scaled[:width]))

    {
      version: OEMBED_VERSION,
      type: 'video',
      width: scaled[:width],
      height: scaled[:height],
      title: resource.title.presence || '', # always include
      author_name: [resource.authors.presence, resource.copyright_notice.presence].compact.join(' / '),
      provider_name: settings.site_title,
      provider_url: absolute_url(''),
      html: oembed_iframe(target_url, scaled[:width], scaled[:height])
    }
  end

  def error_response(err, code)
    render(json: { error: err.to_s }, status: code)
  end

  def absolute_url(path)
    URI.parse(request.base_url).merge(path).to_s
  end

  def oembed_params
    { format: 'json' } # defaults
      .merge(url: params.require(:url))
      .merge(params.permit(:format, :maxwidth, :maxheight).deep_symbolize_keys)
  end

  # NOTE: simpler to concat than templating
  def oembed_iframe(url, width, height)
    <<-HTML.strip_heredoc.tr("\n", ' ')
      <iframe
      width="#{width}"
      height="#{height}"
      frameborder="0"
      allowfullscreen
      src="#{url}"
      ></iframe>
    HTML
  end

  def scale_preview_sizes(entry, ui_minwidth:, ui_minheight:, ui_extraheight:, maxwidth: nil, maxheight: nil)
    # we don't know size of source, but get from largest preview
    source_width = entry.media_file.previews[:videos].map(&:width).max
    source_height = entry.media_file.previews[:videos].map(&:height).max

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
# rubocop:enable Metrics/MethodLength
# rubocop:enable Style/MultilineTernaryOperator
