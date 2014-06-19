module Json
  module ContextGroupHelper

    def hash_for_context_group(context_group, with = nil)
      {
        id: context_group.id,
        name: context_group.name,
        position: context_group.position
      }
    end
  end
end
      
