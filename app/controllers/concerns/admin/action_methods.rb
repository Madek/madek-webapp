module Concerns
  module Admin
    module ActionMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def define_update_action_for(model)
          model_underscored = model.to_s.underscore
          define_method :update do
            @instance = model.find(params[:id])
            @instance.update!(send("update_#{model_underscored}_params"))

            respond_with @instance, location: (lambda do
              send("admin_#{model_underscored}_path", @instance)
            end)
          end
        end

        def define_destroy_action_for(model)
          define_method :destroy do
            @instance = model.find(params[:id])
            @instance.destroy!

            respond_with @instance, location: (lambda do
              send("admin_#{model.model_name.plural}_path")
            end)
          end
        end
      end
    end
  end
end
