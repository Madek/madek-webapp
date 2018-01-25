# rubocop:disable Metrics/MethodLength
class OembedController < ApplicationController

  include EmbedHelper
  include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

  OEMBED_VERSION = Madek::Constants::Webapp::OEMBED_VERSION
  API_ENDPOINT = Madek::Constants::Webapp::OEMBED_API_ENDPOINT
  SUPPORTED_RESOURCES = Madek::Constants::Webapp::EMBED_SUPPORTED_RESOURCES
  SUPPORTED_MEDIA = Madek::Constants::Webapp::EMBED_SUPPORTED_MEDIA
  EMBED_MEDIA_TYPES_MAP = Madek::Constants::Webapp::EMBED_MEDIA_TYPES_MAP

  def show
    # NOTE: this *only* returns JSON, no matter what was requested!
    #       therefore all errors are catched to not trigger rails default behaviour

    # NOTE: `url` accepts anything that Rails recognizes, for simplicity
    #       (so giving the "correct" external hostname is not strictly needed)

    # NOTE: param `sfcss` enables CSS workaround for certain contexts when present

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

    # preview?
    unless resource.try(:media_file).try(:previews).try(:any?)
      return render(json: { error: 'no media!' }, status: 404)
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

  def oembed_response(resource, presenter, params)
    # NOTE: MUST set fixed sizes on iframe, so we need to proportionally scale it!
    #      'minwidth' and 'minheight' is what the UI supports
    #       we respect it but don't return an error (would be correct but no fun)
    scaled = scale_preview_sizes(
      presenter,
      maxwidth: params[:maxwidth], maxheight: params[:maxheight])

    target_url = absolute_url(
      embedded_media_entry_path(
        resource.id,
        height: scaled[:height], width: scaled[:width],
        sfcss: params[:sfcss]))

    {
      version: OEMBED_VERSION,
      type: EMBED_MEDIA_TYPES_MAP[presenter.media_type.to_sym],
      width: scaled[:width],
      height: scaled[:height],
      title: resource.title.presence || '', # always include
      author_name: [
        resource.authors.presence, resource.copyright_notice.presence
      ].compact.join(' / '),
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
      .merge(params.permit(:format, :maxwidth, :maxheight, :sfcss))
      .deep_symbolize_keys
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
