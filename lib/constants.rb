module Constants 
  extend self

  
  PUBLIC_PREFIX= "perm_public_may_"
  PUBLIC_ACTIONS= %w{view download_high_resolution}
  ACTIONS= PUBLIC_ACTIONS.concat %w{manage edit}
  
  NEW_OLD_ACTIONS_MAP = {
      download_high_resolution: :hi_res,
      edit: :edit,
      manage: :manage,
      view: :view
    }


  module Actions 
    include Enumerable
    extend self

    class << self 

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
    include Enumerable
    extend self
  
    def each 
      PUBLIC_ACTIONS.each {|action| yield action}
    end
  end

end
