module Json
  module MetaTermHelper

    def hash_for_meta_term(meta_term, with = nil)
      meta_term.to_s
      {
        id: meta_term.id,
        value: meta_term.to_s
      }
    end
  end
end
