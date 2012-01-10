# -*- encoding : utf-8 -*-
class PermissionsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?

  layout "meta_data"

  def index
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
    end
  end
  
#################################################################

  # creates a JSON
  #
  # { public: permentry
  #  User: [permentries....] 
  #  Group: [permentries....] 
  #  }
  #
  # entry:
  #
  # { id: 20
  # , name: "Fred "
  # , type: "User"
  # , view: true
  # , edit: false
  # }
  #
  #
  #
  #
  # @permissions_json
  # => {"public"=>
  #   {:name=>"Öffentlich",
  #    :type=>"nil",
  #    :view=>false,
  #    :edit=>nil,
  #    :hi_res=>nil,
  #    :manage=>nil},
  #  "Group"=>
  #   [{:id=>1519,
  #     :name=>"MAdeK-Team",
  #     :type=>"Group",
  #     :view=>true,
  #     :edit=>true,
  #     :hi_res=>nil,
  #     :manage=>nil}],
  #  "User"=>
  #   [{:id=>10262,
  #     :name=>"Cahenzli, Ramon",
  #     :type=>"User",
  #     :view=>false,
  #     :edit=>nil,
  #     :hi_res=>nil,
  #     :manage=>nil},
  #    {:id=>159123,
  #     :name=>"Sellitto, Franco",
  #     :type=>"User",
  #     :view=>true,
  #     :edit=>nil,
  #     :hi_res=>nil,
  #     :manage=>true}]}
  #
  def edit_multiple
    
    permissions =  {}

    permissions[:public] = \
      begin 
        h = {:name => "Öffentlich", :type => 'nil'}
        Constants::Actions.each do |action|
          h[Constants::Actions.new2old action] = @resource.send "perm_public_may_#{action}"
        end
        h
      end

    # ASK the type is used in two places why? 
    [User].map{|m| m.to_s.downcase}.each do |subject|
      permissions[subject.capitalize] = @resource.send("#{subject}permissions").map do |permission|
        h = {name: permission.name, id: permission.id, type: subject.capitalize}
        Constants::Actions.each do |action|
          h[Constants::Actions.new2old action] = permission.send "may_#{action}"
        end
        h
      end
    end

    @permissions_json = permissions.to_json

    respond_to do |format|
      format.html
      format.js { render :partial => "edit_multiple" }
    end
  end


 #  params[:subject]
 #  => {"User"=>
 #    {"10262"=>{"view"=>"true", "edit"=>"false", "hi_res"=>"false"},
 #     "159123"=>{"view"=>"true", "edit"=>"false", "hi_res"=>"false"}},
 #   "Group"=>{"1519"=>{"view"=>"true", "edit"=>"true", "hi_res"=>"false"}},
 #   "nil"=>{"view"=>"false", "edit"=>"false", "hi_res"=>"false"}}
 #  
  # REMARK: delete_all is probably used for removing users
  #
  # ASK can we send state: update|delete with each permission .... from the js client? 
  #
  def update_multiple
    ActiveRecord::Base.transaction do
      @resources.each do |resource|
      
        resource.permissions.delete_all
    
        actions = params[:subject]["nil"]
        resource.permissions.build(:subject => nil).set_actions(actions)
  
        ["User", "Group"].each do |key|
          params[:subject][key].each_pair do |subject_id, actions|
            resource.permissions.build(:subject_type => key, :subject_id => subject_id).set_actions(actions)
          end if params[:subject][key]
        end
        
        # OPTIMIZE it's not sure that the current_user is the owner (manager) of the current resource # TODO use Permission.assign_manage_to ?? 
        resource.permissions.where(:subject_type => current_user.class.base_class.name, :subject_id => current_user.id).first.set_actions({:manage => true})
      end
      flash[:notice] = "Die Zugriffsberechtigungen wurden erfolgreich gespeichert."  
    end

    if (@resources.size == 1)
      redirect_to @resources.first
    else
      redirect_back_or_default(resources_path)
    end
  end

#################################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
      when :index
        action = :view
      when :edit_multiple
        if @resources and @resources.empty?
          not_authorized!
          return
        else
          action = :manage
        end
      when :update_multiple
        not_authorized! if @resources.empty?
        return
    end

    # OPTIMIZE if member of a group
    resource = @resource
    not_authorized! unless Permissions.authorized?(current_user, Constants::Actions.old2new(action), resource) # TODO super ??
  end

  def pre_load
    # OPTIMIZE remove blank params
    
    if (not params[:media_entry_id].blank?) and (not params[:media_entry_id].to_i.zero?)
      @resource = MediaEntry.find(params[:media_entry_id])
    elsif not params[:media_entry_ids].blank?
      selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
      @resources = current_user.manageable_media_entries.media_entries.where(:id => selected_ids)
    elsif not params[:media_set_id].blank? # TODO accept multiple media_set_ids ?? 
      selected_ids = [params[:media_set_id].to_i]
      @resources = current_user.manageable_media_sets.where(:id => selected_ids)
      @resource = @resources.first # OPTIMIZE
    else
      flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
      redirect_to :back
    end

    params[:permission_id] ||= params[:id]
    @permission = @resource.permissions.find(params[:permission_id]) unless params[:permission_id].blank?
  end

end
