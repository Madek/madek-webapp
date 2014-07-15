# -*- encoding : utf-8 -*-
class MediaSetsController < ApplicationController

  include Concerns::PreviousIdRedirect
  include Concerns::CustomUrls

  def check_and_initialize_for_view
    @media_set = find_media_resource 
    raise "Wrong type" unless @media_set.is_a? MediaSet
    raise UserForbiddenError unless current_user.authorized?(:view,@media_set)
    @parents_count = @media_set.parent_sets.accessible_by_user(current_user,:view).count
    @can_edit = current_user.authorized?(:edit, @media_set)
    
    # get all individual contexts, sorted by group and position
    @individual_contexts = @media_set.individual_and_inheritable_contexts.sort_by do |context|
      context.context_group_id.to_s + context.position.to_s
    end
    
    # TODO: new query @tom
    @entries_count = @media_set.child_media_resources.accessible_by_user(current_user,:view).count
    @entries_total_count = @media_set.child_media_resources.count
    
    # TODO: queries
    # @entries_with_terms_count = 2342
    # @entries_total_count = 1337

  end

  def check_and_initialize_for_edit
    @media_set = MediaSet.find(params[:id])
    raise UserForbiddenError unless current_user.authorized?(:edit,@media_set)
  end

#####################################################

  def show
    check_and_initialize_for_view

    with = params[:with]
    page = params[:page]
    per_page = (params[:per_page] || PER_PAGE.first).to_i

    respond_to do |format|
      format.html do
        if @media_set.is_a? FilterSet
          @filter_set = @media_set
          render "filter_sets/show"
        else
          @highlights = @media_set.highlights.accessible_by_user(current_user,:view)
        end
      end
      format.json { render json: view_context.json_for(@media_set, with) }
    end
  end

  def browse
    check_and_initialize_for_view
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################
  
  def individual_contexts
    unless check_for_old_id_and_in_case_redirect_to :inheritable_contexts_media_set_path
      check_and_initialize_for_view # sets @media_set, @individual_contexts
      
      if (params[:context_id]).blank?
        raise "No context.id given!"
      end
      
      # find out if each context is inherited and/or enabled
      @count_enabled_contexts = 0
      @individual_contexts.each do |context|
        context.inherited = @media_set.inheritable_contexts.include?(context)
        if @media_set.individual_contexts.include?(context)
          context.enabled = true
          @count_enabled_contexts += 1
        end
      end
      
      if @individual_contexts.blank?
        raise "Tried to show vocabularies, but none exist!"
      end
      
      # get desired context and it's vocabulary - we fetch it from our list because it already contains usefull info (from above)
      @context = @individual_contexts[@individual_contexts.index{|c|c[:id]===params[:context_id]}]
      @vocabulary = ::Vocabulary.build_for_context_set_and_user(@context, @media_set, @current_user)
      @max_usage_count = @vocabulary.map{|key|
        # guard against empty keys
        key[:meta_terms].empty? ? 0 : key[:meta_terms].map{|term|term[:usage_count]}.max
      }.max

    end
  end
  
  
  def enable_individual_context
    check_and_initialize_for_edit
    @context = Context.find(params[:context_id])
    # add to list of individual contexts
    @media_set.individual_contexts << @context
    redirect_to context_media_set_path(@media_set, @context),
      flash: {success: "Das Vokabular \"#{@context}\" wurde für dieses Set aktiviert."}
  end

  def disable_individual_context
    check_and_initialize_for_edit
    @context = Context.find(params[:context_id])
    # remove from list of individual contexts
    @media_set.individual_contexts.delete @context
    
    # decide where to redirect:
    # - if context was not inherited it is removed completely => first context
    # - if that removed context was the last one => main view of set
    if @media_set.individual_and_inheritable_contexts.include? @context
      redirect_to context_media_set_path(@media_set, @context),
        flash: {success: "Das Vokabular \"#{@context}\" wurde für dieses Set deaktiviert."}
    else
      unless @media_set.individual_contexts.empty?
        redirect_target = context_media_set_path(@media_set, @media_set.individual_contexts.first)
      else
        redirect_target = media_set_path
      end
      redirect_to redirect_target,
        flash: {success: "Die Zuweisung des Vokabulars \"#{@context}\" zu diesem Set wurde aufgehoben."}
    end
  end


#####################################################

  def create
    
    attr = params[:media_sets] || params[:media_set]
    filter = params[:filter]
    is_saved = true

    if not attr.blank? and attr.has_key? "0" # CREATE MULTIPLE
      @media_sets = [] 
      attr.each_pair do |k,v|
        media_set = current_user.media_sets.create
        media_set.update_attributes(v)
        media_set.set_meta_data v.slice("meta_data_attributes")
        media_set.update_attributes! v.except("meta_data_attributes")
        @media_sets << media_set
        is_saved = (is_saved and media_set.save)
      end
    else # CREATE SINGLE
      @media_set = current_user.media_sets.create
      @media_set.set_meta_data attr.slice("meta_data_attributes")
      @media_set.update_attributes! attr.except("meta_data_attributes")
      is_saved = @media_set.save
    end

    respond_to do |format|
      format.html do
        if is_saved
          redirect_to media_resources_path(:user_id => current_user, :type => "media_sets")
        else
          flash[:notice] = @media_set.errors.full_messages
          redirect_to :back
        end
      end
      format.json do
        if @media_sets
          render json: view_context.hash_for_media_resources_with_pagination(@media_sets, true).to_json, :status => (is_saved ? 200 : 500)
        else
          render json: view_context.json_for(@media_set), :status => (is_saved ? 200 : 500)
        end
      end
    end
  end
  
#####################################################

  def settings
    check_and_initialize_for_edit
    begin
      @media_set.settings[:layout] = params[:layout].to_sym unless params[:layout].nil?
      @media_set.settings[:sorting] = params[:sorting].to_sym unless params[:sorting].nil?
      @media_set.save
      render :nothing => true, :status => :ok
    rescue
      render :nothing => true, :status => :bad_request
    end
  end


  def parents 
    unless check_for_old_id_and_in_case_redirect_to :parents_media_set 
      check_and_initialize_for_view 
      @parents = @media_set.parent_sets.accessible_by_user(current_user,:view) 
    end
  end

  def category
  end

end
