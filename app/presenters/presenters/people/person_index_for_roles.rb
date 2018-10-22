module Presenters
  module People
    class PersonIndexForRoles < PersonIndex

      attr_reader :roles

      def initialize(app_resource)
        # binding.pry
        super(::Person.find(app_resource.person))
        # @usage_count = count
        # @roles = Role.where(id: roles).map { |r| Presenters::Roles::RoleIndex.new(r) }
        @roles = ::Role.where(id: app_resource.roles).map do |r|
          Presenters::Roles::RoleIndex.new(r)
        end

        # binding.pry
      end

      # delegate_to_app_resource :first_name, :last_name, :pseudonym

      # def url
      #   '/sda'
      # end

      # def label
      #   @app_resource.to_s
      # end

      # def roles
      #   [@app_resource.role].map do |role|
      #     Presenters::Roles::RoleIndex.new(role)
      #   end
      # end

      # def uuid
      #   @app_resource.person.id
      # end

      # attr_reader :usage_count

    end
  end
end
