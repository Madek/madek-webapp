module Concerns
  module Monads
    module FilterChain
      # this monad allows to chain method calls via 'do'
      # applying if a certain param exists otherwise returning
      # the previous resources unchanged
      #
      # Example:
      # FilterChain.new(MediaEntry.all, self)
      #   .do(:filter_by_get_responsible_id, params[:responsible_id])
      #   .do(:filter_by_created_at, params[:created_at]
      #   .return
      #
      FilterChain = Struct.new(:resources, :controller) do
        def do(method_name, param)
          new_resources = if param
                            controller.send(method_name,
                                            resources,
                                            param)
                          else
                            resources
                          end
          FilterChain.new(new_resources, controller)
        end
        alias_method :return, :resources
      end
    end
  end
end
