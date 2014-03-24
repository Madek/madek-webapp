class Api::MediaResourcesController <  ApiController

  def chain_authorized_for media_resources, authorized_for
    case authorized_for.to_sym
    when :view
      media_resources.accessible_by_api_application(@api_application, :view)
    when :download
      media_resources.accessible_by_api_application(@api_application, :download)
    else
      raise " #{authorized_for} is not a legal value for the authorized_for key"
    end
  end

  def index
    begin 
      params[:page] ||= 1
      query_params = params.select{|k| [:page,:type].include? k.to_sym}.clone

      media_resources= MediaResource.reorder(created_at: :asc)

      if not params[:authorized_for]
        media_resources= media_resources.accessible_by_api_application(@api_application, :view)
      elsif params[:authorized_for].is_a? Array
        params[:authorized_for].each do |authorized_for|
          media_resources= chain_authorized_for media_resources, authorized_for
        end
      else 
        media_resources= chain_authorized_for media_resources, params[:authorized_for]
      end

      total_count= media_resources.limit(10000).count

      media_resources.instance_eval do
        self.class.send :define_method, :total_count do
          total_count
        end
        self.class.send :define_method, :query_params do
          query_params
        end
      end

      if type=params[:type]
        media_resources = media_resources.where(type: type)
      end

      if media_type= params[:media_type]
        media_resources = media_resources.joins(:media_file).where("media_files.media_type = ?",media_type)
      end


      media_resources = media_resources.page(params[:page])

      render json: API::MediaResourcesRepresenter.new(media_resources).as_json
    rescue Exception => e
      render json: {error: e.to_s}, status: 422
    end
  end

  def show
    @media_resource= MediaResource.find(params[:id])
    render json: API::MediaResourceRepresenter.new(@media_resource).as_json.to_json
  end

end
