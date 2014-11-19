class Grouppermission < ActiveRecord::Base

  ALLOWED_PERMISSIONS = [:view,:download,:edit]

  belongs_to :group
  belongs_to :media_resource

  delegate :name, to: :group

  def self.destroy_irrelevant
    Grouppermission.where(view: false, edit: false, download: false, manage: false).destroy_all
  end

  def active_permissions
    [].tap do |values|
      ALLOWED_PERMISSIONS.each do |allowed_permission|
        values << allowed_permission if send(allowed_permission) == true
      end
    end
  end
end
