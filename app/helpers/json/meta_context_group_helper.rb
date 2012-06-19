module Json
  module MetaContextGroupHelper

    def hash_for_meta_context_group(meta_context_group, with = nil)
      {
        id: meta_context_group.id,
        name: meta_context_group.name,
        position: meta_context_group.position
      }
    end
  end
end
      