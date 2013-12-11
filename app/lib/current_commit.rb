class CurrentCommit

  class << self 

    def get
      if Rails.env.development?
        _get 
      else
        @_current_commit ||= _get
      end
    end

    def _get
      git = Git.open(Rails.root)
      git.gcommit git.log(1)
    end

  end

end
