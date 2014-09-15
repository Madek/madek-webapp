# -*- encoding : utf-8 -*-

##
# MediaResources are the core content of MAdeK. They are seperated in MediaEntries and MediaSets (Collection of MediaResources).
# 
class MediaResourcesController < ApplicationController

  include Concerns::PreviousIdRedirect
  include Concerns::CustomUrls

  before_filter :except => [:index, :collection, :destroy] do
    begin
      unless (params[:media_resource_id] ||= params[:id] || params[:media_resource_ids] || params[:collection_id]).blank?
        action = case request[:action].to_sym
          when :edit
            :edit
          else
            :view
        end
        @media_resource = if params[:collection_id]
          MediaResource.accessible_by_user(current_user, action).where(:id => MediaResource.by_collection(params[:collection_id]))
        else
          MediaResource.accessible_by_user(current_user, action).find(params[:media_resource_id])
        end
      end
    rescue
      raise UserForbiddenError
    end
  end


  def index()

    with_filter = params[:with_filter]
    with = params[:with] || {}
    sort = params[:sort]
    page = params[:page]
    per_page = [(params[:per_page] || PER_PAGE.first).to_i.abs, PER_PAGE.last].min

    @filter = MediaResource.get_filter_params params

    respond_to do |format|
      format.html { @media_resources_count = MediaResource.accessible_by_user(current_user,:view).count }
      format.json {
        resources = MediaResource.filter(current_user, @filter).ordered_by(sort)

        h = case with_filter

            when "true"
              view_context.hash_for_media_resources_with_pagination(resources, \
                      {:page => page, :per_page => per_page}, with, false) \
                      .merge({:filter => view_context.hash_for_filter(resources)})

            when "only"
            {:filter => view_context.hash_for_filter(resources)}
          
            else
              view_context.hash_for_media_resources_with_pagination(resources, \
                {:page => page, :per_page => per_page}, with, false)

          end

        render json: h.merge(:current_filter => @filter).to_json
      }
    end
  end

  def show
    flash.keep
    case @media_resource
    when FilterSet
      redirect_to filter_set_path(@media_resource)
    when MediaEntry, MediaEntryIncomplete
      redirect_to media_entry_path(@media_resource)
    when MediaSet
      redirect_to media_set_path(@media_resource)
    else
      raise "missing dispatch on #{@media_resource.type}"
    end
  end

  def browse
    @browsable_meta_terms = []
    @media_resource.meta_data.for_meta_terms.each do |meta_datum|
      meta_datum.value.each do |meta_term|
        count = MediaResource.filter(current_user, {:meta_data => {meta_datum.meta_key.label.to_sym => {:ids => [meta_term.id]}}}).where("media_resources.id != ?", @media_resource.id).count
        if count > 0
          data = {:meta_term => meta_term, :meta_datum => meta_datum, :count => count}
          if @media_resource.individual_contexts[0] and @media_resource.individual_contexts[0].meta_keys.where(:id => meta_datum.meta_key).exists?
            @browsable_meta_terms.unshift data
          else
            @browsable_meta_terms.push data
          end
        end
      end
    end
  end

  def edit
    @contexts =
      case @media_resource
      when MediaEntry
        Context.defaults + @media_resource.individual_contexts
      when MediaSet, FilterSet
        [Context.find_by_id(:media_set)]
      else
        raise "Add the class #{@media_resource.class} to dispatching"
      end

    @meta_data = {}
    @contexts.each {|context| @meta_data[context.id] = @media_resource.meta_data.for_context(context) }
  end


  def destroy
    begin
      ActiveRecord::Base.transaction do
        if MediaResource.where(id: params[:id]).empty?
          render json: {}, status: 204
        elsif (media_resource=MediaResource.find(params[:id])) and current_user.authorized?(:delete, media_resource)
          media_resource.destroy
          render json: {}, status: 204
        else 
          render json: {}, status: 403
        end
      end
    rescue Exception => e
      logger.error Formatter.error_to_s e
      render json: {}, status: 422 
    end
  end

  ########################################################################

  def collection(ids = params[:ids] || raise("ids are required"),
                 relation = params[:relation],
                 collection_id = params[:collection_id])
    if request.post? and ids
      ids = case relation
        when "parents"
          MediaResource.where(:id => ids).flat_map do |child|
            child.parent_sets.accessible_by_user(current_user,:view).pluck("media_resources.id")
          end.uniq
        else
          ids
      end

      collection = Collection.add ids, collection_id
    end

    respond_to do |format|
      format.json { render json: {collection_id: collection[:id]} }
    end
  end

###################################################################################

  def toggle_favorites
    current_user.favorites.toggle(@media_resource)
    respond_to do |format|
      format.js { render :partial => "favorite_link", :locals => {:media_resource => @media_resource} }
    end
  end

  def favor
    current_user.favorites.favor(@media_resource)
    respond_to do |format|
      format.json { render :nothing => true, :status => :no_content }
    end
  end

  def disfavor
    current_user.favorites.disfavor(@media_resource)
    respond_to do |format|
      format.json { render :nothing => true, :status => :no_content }
    end
  end


  def parents()

    parent_media_set_ids = params[:parent_media_set_ids]
    parent_media_sets = MediaSet.accessible_by_user(current_user, :edit).where(:id => parent_media_set_ids)
    child_resources = Array(@media_resource)

    child_resources.each do |resource|
      if request.post?
        (parent_media_sets - resource.parent_sets).each do |parent_media_set|
          resource.parent_sets << parent_media_set
          if resource.is_a? MediaSet
            individual_contexts = parent_media_set.individual_contexts.reject{|context| resource.individual_contexts.include? context}
            resource.individual_contexts << individual_contexts unless individual_contexts.blank?
          end
        end
      elsif request.delete?
        parent_media_sets.each do |parent_media_set|
          resource.parent_sets.delete(parent_media_set)
          if resource.is_a? MediaSet
            resource.individual_contexts = resource.individual_contexts.reject{|context| not resource.inheritable_contexts.include? context}
          end
        end
      end
    end
    flash[:notice] = "Zusammenhänge aktualisiert."
    respond_to do |format|
      format.json {
        render :json => view_context.json_for(child_resources, {:parents => true})
      }
    end
  end

###################################################################################


  def image(size = (params[:size] || :large).to_sym)

    if size == :maximum and not current_user.authorized? :download, @media_resource
      size = :x_large
    end

    # TODO dry => Resource#thumb_base64 and Download audio/video
    media_file = @media_resource.get_media_file(current_user)

    if (not media_file) and @media_resource.is_a? MediaSet or (not media_file)
      # empty gif pixel
      output = "R0lGODlhAQABAIAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==\n"
      send_data Base64.decode64(output), :type => "image/gif", :disposition => 'inline'
    else
      preview = media_file.get_preview(size, "image/jpeg")
      if preview and File.exist?(file = File.join(THUMBNAIL_STORAGE_DIR, media_file.shard, preview.filename))
        output = File.read(file)
        send_data output, :type => preview.content_type, :disposition => 'inline'
      else
        output = media_file.thumb_placeholder(size)
        send_data output, :type => "image/png", :disposition => 'inline'
      end
    end
  end  

end

