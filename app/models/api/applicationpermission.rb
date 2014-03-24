class API::Applicationpermission < ActiveRecord::Base 
  belongs_to :media_resource
  belongs_to :application 

  def self.destroy_irrelevant
    API::Applicationpermission.where(view: false, edit:false, download: false,manage: false).delete_all
  end

end
