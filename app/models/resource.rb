# -*- encoding : utf-8 -*-

class Resource < ActiveRecord::Base

  include Concerns::ResourcesThroughPermissions

  self.record_timestamps= false

  has_and_belongs_to_many :collection_media_entry_arcs

  belongs_to :responsible_user, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  belongs_to :updator, class_name: 'User'

  
  has_many :custom_urls

  has_many  :edit_sessions, :dependent => :destroy
  has_many  :editors, through: :edit_sessions, source: :user

  default_scope { reorder(:created_at,:id) }

  ### custom_urls #############################################################
   
  has_many :custom_urls

  def primary_custom_url 
    custom_urls.where(is_primary: true).first
  end


end
