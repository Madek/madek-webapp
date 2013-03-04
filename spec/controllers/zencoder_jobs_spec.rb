require 'spec_helper'

describe ZencoderJobsController do
  render_views

  before :all do
    ENV['ZENCODER_CONFIG_FILE']= (Rails.root.join "features","data","zencoder.yml").to_s
    FactoryGirl.create :usage_term
    FactoryGirl.create :meta_key, :label => "copyright status", :meta_datum_object_type => "MetaDatumCopyright"
    FactoryGirl.create :meta_key, :label => "description author", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, :label => "description author before import", :meta_datum_object_type => "MetaDatumPeople"
    FactoryGirl.create :meta_key, :label => "uploaded by", :meta_datum_object_type => "MetaDatumUsers"
    FactoryGirl.create :meta_context, name: 'io_interface', is_user_interface: false
    FactoryGirl.create :meta_context, name: 'upload', is_user_interface: false
    @user = FactoryGirl.create :user
    @media_entry_incomplete_for_image= (FactoryGirl.create :media_entry_incomplete, user: @user)
    @media_entry_incomplete_for_movie = (FactoryGirl.create :media_entry_incomplete_for_movie, user: @user)
    @zencoder_job = (ZencoderJob.create media_file: @media_entry_incomplete_for_movie.media_file)
  end

  context "a finished_zencoder job" do

    before :each do
      @zencoder_job.update_attributes state: 'finished'
    end

    describe "post_notification" do
      it "is successful" do
        post  :post_notification, {format: :json, id: @zencoder_job.id}, {}
        expect(response).to be_success
      end
    end
  end

end




