module Json
  module MetaKeyHelper

    def hash_for_meta_key(meta_key, with = nil)
      {
        id: meta_key.id,
        name: meta_key.to_s
      }
    end
  end
end
