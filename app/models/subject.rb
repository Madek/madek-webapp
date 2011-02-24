# -*- encoding : utf-8 -*-
module Subject

  def self.included(base)
    base.has_many :permissions, :as => :subject, :dependent => :destroy
  end

end
