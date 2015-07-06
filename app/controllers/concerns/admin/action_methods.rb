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
      end
    end
  end
end
