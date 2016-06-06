module Presenters
  class HashPresenter < Presenter

    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end
  end
end
