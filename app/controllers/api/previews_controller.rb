class Api::PreviewsController < ApiController
  def index
    previews= Preview.joins(:media_file).where("media_files.media_entry_id = ?",  params[:id])

    params[:page] ||= 1
    query_params = params.select{|k| [:page].include? k.to_sym}.merge({id: params[:id]}).clone

    total_count= previews.limit(10000).count

    previews.instance_eval do
      self.class.send :define_method, :total_count do
        total_count
      end
      self.class.send :define_method, :query_params do
        query_params
      end
    end

    previews= previews.page(params[:page])

    render json: API::PreviewsRepresenter.new(previews).as_json
  end

  def show
    preview= Preview.find(params[:id])
    render json: API::PreviewRepresenter.new(preview).as_json
  end

  def content_stream
    @preview= Preview.find(params[:preview_id])
    send_file @preview.full_path,  
      type: @preview.content_type,
      disposition: 'inline'
  end

end
