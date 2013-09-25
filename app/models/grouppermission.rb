class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource

  delegate :name, to: :group

  def self.destroy_irrelevant
    Grouppermission.where(view: false, edit:false, download: false,manage: false).destroy_all
  end



end
