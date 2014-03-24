class API::Application < ActiveRecord::Base
  belongs_to :user

  default_scope lambda{ reorder(id: :asc) }

  validates :id, format: {with: /\A[a-z][a-z0-9_-]+\z/, 
                          message: %[only alpha-numeric ascii characters as well as dashes and underscores are allowed, 
                                    first character must be a letter, all letters must be lowercase]}
  validates :id, length: {in: 3..20}
end
