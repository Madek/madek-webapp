# -*- encoding : utf-8 -*-
class Admin::AdminController < ApplicationController

  layout "admin/main"

  before_filter do
    # FIXME zhdk specific 
    required_group = Group.find_by_name("Admin")
    unless current_user.groups.is_member?(required_group)
      # 10262 => Ramon Cahenzli
      # 10301 => Susanne Schumacher
      # 159123 => Franco Sellitto
      # 182749 => Thomas Schank
      # 170371 => Sebastian Pape
      if [10262, 10301, 159123, 182749, 170371].include?(current_user.id)
        required_group.users << current_user
      else
        flash[:error] = "The function you wish to use is only available to admin users"
        redirect_to root_path
      end
    end
  end


  def settings
    if request.post?
      params[:settings][:authentication_systems] = Array(params[:settings][:authentication_systems]).map{|x| x.to_sym} if params[:settings][:authentication_systems]

      params[:settings].each_pair do |k,v|
        AppSettings.send("#{k}=", v)
      end

      flash[:notice] = "Updated"
    end
  end

end
