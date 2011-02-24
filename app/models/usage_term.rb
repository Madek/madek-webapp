# -*- encoding : utf-8 -*-
class UsageTerm < ActiveRecord::Base
  
  def self.current
    r = first
    r ||= create(:title => "Nutzungsbedingungen")
  end
end