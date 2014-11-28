class FilterSet < ActiveRecord::Base

  belongs_to :responsible_user, class_name: "User"
  belongs_to :creator, class_name: "User"

  has_many :keywords

  has_many :edit_sessions, dependent: :destroy
  has_many :editors, through: :edit_sessions, source: :user

end
