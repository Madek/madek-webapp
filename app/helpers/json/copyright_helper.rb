module Json
  module CopyrightHelper

    def hash_for_copyright(copyright, with = nil)
        h = copyright.as_json
        h["children"] = copyright.children
        h["children"].each do |child|
          child["children"] = child.children
        end
        h
    end
  end
end
      