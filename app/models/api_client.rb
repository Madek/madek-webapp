class ApiClient < ActiveRecord::Base
  belongs_to :user

  attr_accessor :authorization_header

  has_secure_password validations: false

  default_scope { reorder(id: :asc) }

  validates :login,
            format: {
              with: /\A[a-z][a-z0-9_-]+\z/,
              message: %(
                only alpha-numeric ascii characters as well \
                as dashes and underscores are allowed, \
                first character must be a letter, \
                all letters must be lowercase
              )
            }

  validates :login, length: { in: 3..20 }

end
