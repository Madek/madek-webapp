module Json
  module CopyrightHelper

    def hash_for_copyright(copyright, with = nil)
      copyright.as_json(:include => {:children => {:include => :children}})
    end
  end
end
      