# NOTE: as the name indicates, only used in test env
class OnlyForTestController < ApplicationController
  def error_500
    raise 'error 500'
  end
end
