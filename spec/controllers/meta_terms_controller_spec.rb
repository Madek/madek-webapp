require 'spec_helper'

describe MetaTermsController do
  render_views

  before :all do
    @meta_context= FactoryGirl.create :meta_context
    @meta_key= FactoryGirl.create :meta_key
    @meta_key_definition= FactoryGirl.create :meta_key_definition
  end

  after :all do
    @meta_context.destroy
  end

end

