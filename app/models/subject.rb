# -*- encoding : utf-8 -*-
module Subject

  def self.included(base)
    base.has_many :permissions, :as => :subject, :dependent => :destroy

################################
=begin
    #tmp#
    base.has_many :accessible_permissions, :class_name => "Permission", :as => :subject,
                        :conditions => "action_bits & 1 AND action_mask & 1"
                        #where("(subject_type = 'Group' AND subject_id IN (?)) OR (subject_type = 'User' AND subject_id = ?)", user.groups, user.id).
                        #where("action_bits & #{i} AND action_mask & #{i}").

    base.has_many :accessible_resources, :through => :accessible_permissions, :source => :resource
=end
################################

  end

end
