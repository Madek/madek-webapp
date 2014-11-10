module Concerns
  module MediaResourceAspect
    extend ActiveSupport::Concern

    included do

      belongs_to :resource, foreign_key: 'id'

      delegate :responsible_user, to: :resource
      delegate :creator, to: :resource
      delegate :updator, to: :resource


      before_create do |me|
      end

      after_destroy do |me|
        me.resource.destroy
      end

      before_save do |me|
      end

    end


  end
end


