# rubocop:disable Metrics/MethodLength
# rubocop:disable Style/MultilineTernaryOperator
class OembedController < ApplicationController

  include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

  API_ENDPOINT = '/oembed'.freeze
  # naming like controllers, only is supposed to work for "resourcefull routes"!
  SUPPORTED_RESOURCES = ['media_entries'].freeze

  # # if a config (according to oEmbed spec) needed to be built, it would be like:
  # OEMBED_CONFIG = [{ # pairs of supported URL schemes and their API endpoint
  #     url_scheme: 'https://madek.example.com/entries/*',
  #     api_endpoint: 'https://madek.example.com/oembed'
  # }]

  def show
    # NOTE: this *only* returns JSON, no matter what was requested!
    #       therefore all errors are catched to not trigger rails default behaviour

    # NOTE: `url` accepts anything that Rails recongnizes,
    # this is easier than finding out the "external_base_url".

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

    presenter = presenter_by_class(resource_class).new(resource, current_user)
    render(json: oembed_response(presenter, params))
  end

  private

  # NOTE: only 'video' type supported
  def oembed_response(resource, params)
    source_height = resource.media_file.previews[:videos].map(&:height).max
    source_width = resource.media_file.previews[:videos].map(&:width).max
    height = params[:maxheight].nil? || source_height <= params[:maxheight].to_i \
      ? source_height : params[:maxheight]
    width = params[:maxwidth].nil? || source_width <= params[:maxwidth].to_i \
      ? source_width : params[:maxwidth]

    target_url = absolute_url(
      embedded_media_entry_path(resource.uuid, maxheight: height, maxwidth: width))

    {
      version: '1.0',
      type: 'video',
      width: width,
      height: height,
      title: resource.title.presence || '', # always include
      author_name: resource.authors_pretty.presence, # only include if present
      provider_name: settings.site_title,
      provider_url: absolute_url(''),
      html: oembed_iframe(target_url, width, height)
    }
  end

  def error_response(err, code)
    render(json: { error: err.to_s }, status: code)
  end

  def absolute_url(path)
    # appends path to base_url, forces HTTPS!
    URI.parse(request.base_url).merge(path).tap { |u| u.scheme = 'https' }.to_s
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

end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Style/MultilineTernaryOperator
