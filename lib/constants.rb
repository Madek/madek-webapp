module Constants 
  extend self

  
  PUBLIC_PREFIX= "perm_public_may_"
 
  NEW_OLD_PUBLIC_ACTIONS_MAP =  \
    { download: :hi_res \
    , view: :view
    }

  NEW_OLD_ACTIONS_MAP = NEW_OLD_PUBLIC_ACTIONS_MAP.merge (
    { edit: :edit \
    , manage: :manage
    })

  PUBLIC_ACTIONS= NEW_OLD_PUBLIC_ACTIONS_MAP.keys
  ACTIONS= NEW_OLD_ACTIONS_MAP.keys


  module Actions 
    extend self

    class << self 
      include Enumerable

      def new2old old_action
        Constants::NEW_OLD_ACTIONS_MAP.fetch old_action.to_sym
      end

      def old2new new_action
        Constants::NEW_OLD_ACTIONS_MAP.invert.fetch new_action.to_sym
      end

      def each
        ACTIONS.each {|action| yield action}
      end

    end

  end

  
  module PublicActions
    extend self

    class << self
      include Enumerable

      def each 
        PUBLIC_ACTIONS.each {|action| yield action}
      end
    end
  end

end
