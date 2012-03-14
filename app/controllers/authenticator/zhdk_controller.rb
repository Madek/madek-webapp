# -*- encoding : utf-8 -*-
require 'net/http' 
require 'net/https'
require 'cgi'

class Authenticator::ZhdkController < ApplicationController
  
  
  AUTHENTICATION_URL = 'http://www.zhdk.ch/?auth/madek'
  APPLICATION_IDENT = 'fc7228cdd9defd78b81532ac71967beb'
    
  def login
    if Rails.env.development? and params["bypass"]
      if params["bypass"]== "true"
        session[:user_id] = create_or_update_user(DevelopmentHelpers::AUTH_XML)
      elsif user = User.where("login = ?",params["bypass"]).first || (Persona.create params["bypass"])
        session[:user_id] = user.id
      end
      (User.find session[:user_id]).usage_terms_accepted!
      redirect_to root_path
    else
      target = AUTHENTICATION_URL + "&url_postlogin=" + CGI::escape("http://#{request.host}:#{request.port}#{url_for('/authenticator/zhdk/login_successful/%s')}")
      redirect_to target
    end
  end

  def login_successful(session_id = params[:id])
    response = fetch("#{AUTHENTICATION_URL}/response&agw_sess_id=#{session_id}&app_ident=#{APPLICATION_IDENT}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      session[:user_id] = create_or_update_user(xml["authresponse"]["person"]) # self.current_user =
      redirect_to root_path
    else
      render :text => "Authentication Failure. HTTP connection failed - response was #{response.code}" 
    end
  end

  def logout
    reset_session
    flash[:notice] = "Sie haben sich abgemeldet." #"You have been logged out."
    redirect_to root_path
  end
      
  private 
  
  def fetch(uri_str, limit = 10)
     raise ArgumentError, 'HTTP redirect too deep' if limit == 0

     uri = URI.parse(uri_str)
     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true if uri.port == 443
     response = http.get(uri.path + "?" + uri.query)
     case response
     when Net::HTTPSuccess     then response
     when Net::HTTPRedirection then fetch(response['location'], limit - 1)
     else
         response.error!
     end
  end

  def create_or_update_user(xml)
    user = User.where(:id => xml["id"]).first # TODO use xml["uniqueid"] ??
    if user.nil?
      person = Person.find_or_create_by_firstname_and_lastname(:firstname => xml["firstname"],
                                                               :lastname => xml["lastname"])
      user = person.build_user(:login => xml["local_username"],
                               :email => xml["email"])
      user.id = xml["id"]
      user.save
    end
    if user
      g = xml['memberof']['group'].map {|x| x.gsub("zhdk/", "") }
      new_groups = MetaDepartment.where(:ldap_name => g)
      to_add = (new_groups - user.groups.departments)
      to_remove = (user.groups.departments - new_groups)
      user.groups << to_add
      user.groups.delete(to_remove)
      
      zhdk_group = Group.where(:name => "ZHdK (Zürcher Hochschule der Künste)").first
      user.groups << zhdk_group unless user.groups.include?(zhdk_group) 
      
      user.id
    end
  end
  
end
