# encoding: utf-8
class CustomUrlsController < ApplicationController

  # TODO: consilidate with general error handling
  class EagerCustomURLCreation < Exception; end
  class ::NotAuthorized < Exception; end

  include Concerns::CustomUrls

  before_action :set_messages

  helper_method :url_transfer_authorized? 
  helper_method :create_url_authorized?

  def url_transfer_authorized? media_resource, custom_url
    current_user.authorized?(:manage,media_resource) \
      and current_user.authorized?(:manage,custom_url.media_resource)
  end

  def create_url_authorized?
    current_user.authorized?(:manage,@media_resource)
  end

  def set_messages
    [:error,:warning,:notice,:success].each do |level|
      if message= params[level]
        flash[level]= message
      end
    end
    
  end

  def index
    @media_resource= MediaResource.find params[:id]
    raise NotAuthorized unless current_user.authorized?(:view, @media_resource)
    @custom_urls= CustomUrl.where(media_resource_id: params[:id])
    render status: flash[:http_code] if flash[:http_code]
  end

  def new
    raise NotAuthorized unless create_url_authorized?
    @media_resource= MediaResource.find params[:id]
    render status: flash[:http_code] if flash[:http_code]
  end

  def create
    begin
      @media_resource= MediaResource.find params[:id]
      raise NotAuthorized unless create_url_authorized?
      if not current_user.act_as_uberadmin and 
        not @media_resource.custom_urls.where("created_at > ?", (Time.zone.now - 3.minutes)).empty?
        raise EagerCustomURLCreation 
      end
      CustomUrl.create id: params[:url], media_resource: @media_resource, 
        creator: current_user, updator: current_user
      redirect_to custom_urls_path(@media_resource), flash: {success: "Die Adresse wurde angelegt."}
    rescue EagerCustomURLCreation => e
      redirect_to new_custom_url_path(@media_resource,url: params[:url]), 
        flash: {http_code: 422, 
                error:  "Es kann maximal eine Adresse im Zeitraum von 3 Minuten für einen Inhalt erzeugt werden. Bitte warten Sie."}
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to confirm_url_transfer_media_resource_path(@media_resource,url: params[:url]) 
    rescue NotAuthorized => e
      redirect_to custom_urls_path(@media_resource,url: params[:url]),
        flash: {http_code: 403, error:  "Sie haben nicht die notwendige Berechtigung."} 
    rescue ActiveRecord::StatementInvalid => e
      case e.original_exception
      when PG::CheckViolation
        redirect_to new_custom_url_path(@media_resource,url: params[:url]), 
          flash: {error:  "Die Adresse entspricht nicht den Anforderungen."} 
      else
        raise e.original_exception
      end
    rescue Exception => e
      raise e
    end
  end

  def confirm_url_transfer
    @custom_url= CustomUrl.find params[:url]
    @media_resource= MediaResource.find params[:id]
    render status: flash[:http_code] if flash[:http_code]
  end

  def transfer_url 
    begin
      @custom_url= CustomUrl.find params[:url]
      @media_resource= MediaResource.find params[:id]
      raise NotAuthorized unless url_transfer_authorized?(@media_resource,@custom_url)       
      @custom_url.update_attributes! media_resource: @media_resource, is_primary: false, \
        updator: current_user
      redirect_to custom_urls_path(@media_resource), flash: {success: "Die Adresse wurde erfolgreich übertragen."}
    rescue NotAuthorized => e
      redirect_to confirm_url_transfer_media_resource_path(@media_resource,url: params[:url]), 
        flash: {http_code: 403, error: "Sie sind nicht berechtigt diese Adresse zu übertragen."}
    end
  end

  def set_primary_url
    begin
      ActiveRecord::Base.transaction do
        @media_resource= MediaResource.find params[:id]
        raise NotAuthorized unless current_user.authorized?(:manage,@media_resource)
        @media_resource.custom_urls.each do |cu|
          if cu.is_primary
            cu.update_attributes! is_primary: false, updator: current_user
          end
        end
        @custom_url= CustomUrl.find_by(id: params[:url], media_resource_id: @media_resource.id)
        @custom_url.update_attributes!(is_primary: true, updator: current_user) if @custom_url
      end
      redirect_to custom_urls_path(@media_resource), flash: {success: "Eine neue primäre Adresse wurde gesetzt."}
    rescue NotAuthorized => e
      redirect_to confirm_url_transfer_media_resource_path(@media_resource), 
        flash: {error: "Sie sind nicht berechtigt diese Aktion auszuführen."}
    end
  end

end
