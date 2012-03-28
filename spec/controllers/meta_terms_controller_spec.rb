require 'spec_helper'

describe MetaTermsController do
  render_views

  before :all do
    @description= FactoryGirl.create :meta_term
    @hint = FactoryGirl.create :meta_term
    @label= FactoryGirl.create :meta_term
    @meta_context= FactoryGirl.create :meta_context
    @meta_key= FactoryGirl.create :meta_key
    @meta_key_definition= FactoryGirl.create :meta_key_definition, meta_context: @meta_context, meta_key: @meta_key, 
      label: @label, hint: @hint, description: @description
  end

  after :all do
    @meta_key_definition.destroy
    @meta_key.destroy
    @meta_context.destroy
    @description.destroy
    @hint.destroy
    @label.destroy
  end

end

