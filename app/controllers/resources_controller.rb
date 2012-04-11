# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  def index(type = params[:type],
            top_level = params[:top_level],
            user_id = params[:user_id],
            media_set_id = params[:media_set_id],
            not_by_current_user = params[:not_by_current_user],
            public = params[:public],
            favorites = params[:favorites],
            sort = params[:sort] ||= "updated_at",
            query = params[:query],
            page = params[:page],
            per_page = (params[:per_page] || PER_PAGE.first).to_i,
            meta_key_id = params[:meta_key_id],
            meta_term_id = params[:meta_term_id] )

    respond_to do |format|
      format.html
      format.json {
        resources = if favorites == "true"
          current_user.favorites
        else
          MediaResource
        end
    
        resources = case type
          when "media_sets"
            r = resources.where(:type => "MediaSet")
            r = r.top_level if top_level
            r
          when "media_entries"
            resources.where(:type => "MediaEntry")
          else
            resources.media_entries_and_media_sets
        end.accessible_by_user(current_user)

        case sort
        when "updated_at", "created_at"
          resources = resources.order("media_resources.#{sort} DESC")
        when "random"
          if SQLHelper.adapter_is_mysql?
            resources = resources.order("RAND()")
          elsif SQLHelper.adapter_is_postgresql? 
            resources = resources.order("RANDOM()")
          else
            raise "SQL Adapter is not supported" 
          end
        end

        resources = resources.by_media_set(media_set_id) if media_set_id
        resources = resources.by_user(@user) if user_id and (@user = User.find(user_id))
        if not_by_current_user
          resources = resources.not_by_user(current_user)
          case public
            when "true"
              resources = resources.where(:view => true)
            when "false"
              resources = resources.where(:view => false)
          end
        end
        
        resources = resources.search(query) unless query.blank?
        resources = resources.paginate(:page => page, :per_page => per_page)
    
        # TODO ?? resources = resources.includes(:meta_data, :permissions)
    
        if meta_key_id and meta_term_id
          meta_key = MetaKey.find(meta_key_id)
          meta_term = meta_key.meta_terms.find(meta_term_id)
          media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
          resources = resources.where(:id => media_resource_ids)
        end
        
        with_thumb = true #FE# (params[:thumb].to_i > 0)
        
        @resources = { :pagination => { :current_page => resources.current_page,
                                       :per_page => resources.per_page,
                                       :total_entries => resources.total_entries,
                                       :total_pages => resources.total_pages },
                      :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) }

        render :json => @resources
      }
    end
  end
  
  # TODO merge search and filter methods ??
  def filter(query = params[:query],
             page = params[:page],
             per_page = (params[:per_page] || PER_PAGE.first).to_i,
             meta_key_id = params[:meta_key_id],
             meta_term_id = params[:meta_term_id],
             filter = params[:filter] )
             
    # TODO generic search for both MediaResource.media_entries_and_media_sets
    resources = MediaEntry.accessible_by_user(current_user)
 
    if request.post?
      if meta_key_id and meta_term_id
        meta_key = MetaKey.find(meta_key_id)
        meta_term = meta_key.meta_terms.find(meta_term_id)
        media_resource_ids = meta_term.meta_data(meta_key).collect(&:media_resource_id)
      else
        if params["MediaEntry"] and params["MediaEntry"]["media_type"]
          resources = resources.filter_media_file(params["MediaEntry"])
        end
        media_resource_ids = filter[:ids].split(',').map(&:to_i) 
      end
  
      with_thumb = true #FE# (params[:thumb].to_i > 0)

      resources = resources.where(:id => media_resource_ids).paginate(:page => page, :per_page => per_page)
      @resources = { :pagination => { :current_page => resources.current_page,
                                     :per_page => resources.per_page,
                                     :total_entries => resources.total_entries,
                                     :total_pages => resources.total_pages },
                    :entries => resources.as_json(:user => current_user, :with_thumb => with_thumb) } 
  
      respond_to do |format|
        format.json { render :json => @resources.to_json }
      end

    else

      @resources = resources.search(query)
  
      respond_to do |format|
        format.js { render :layout => false}
      end
    end
  end

end
