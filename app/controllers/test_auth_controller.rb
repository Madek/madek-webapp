class TestAuthController < ApplicationController

  def step1
    skip_authorization
  end

  def step2
    skip_authorization
  end

end
