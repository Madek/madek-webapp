module Constants 
  extend self

  #TODO refactor this into a module with old2new 
  
  
  PUBLIC_PREFIX= "perm_public_may_"
  PUBLIC_ACTIONS= %w{view download_high_resolution}
  ACTIONS= PUBLIC_ACTIONS.concat %w{manage edit}
  


  
  module PublicActions
    include Enumerable
    extend self
  
    def each 
      PUBLIC_ACTIONS.each {|action| yield action}
    end
  end

end
