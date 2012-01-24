require 'spec_helper'

include Rack::Test::Methods

describe MediaSetsController, type: :api do

  

  it "should respond" do

    get "/"

    response.should be_success

  end


end

