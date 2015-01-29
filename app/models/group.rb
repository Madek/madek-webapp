class Group < ActiveRecord::Base
  include Concerns::Groups::Filters
  include Concerns::Groups::Searches

  has_and_belongs_to_many :users

  after_save :update_searchable

  validates_presence_of :name
  validates :name, uniqueness: { scope: :institutional_group_name }

  scope :departments, -> { where(type: 'InstitutionalGroup') }

  scope :by_type, lambda { |type|
    where(type: type.classify)
  }

  def merge_to(receiver)
    Group.transaction do
      merge_users_to(receiver)
      delete
    end
  end

  def merge_users_to(receiver)
    users.each do |user|
      receiver.users << user unless receiver.users.exists?(id: user.id)
    end
    users.clear
  end

  def update_searchable
    update_columns searchable: [name, institutional_group_name].flatten \
      .compact.sort.uniq.join(' ')
  end
end
