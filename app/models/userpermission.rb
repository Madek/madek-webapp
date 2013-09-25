class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource
  belongs_to :user 

  def self.destroy_irrelevant
    Userpermission.where(view: false, edit:false, download: false,manage: false).destroy_all
  end

end
