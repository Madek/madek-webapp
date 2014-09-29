require 'spec_helper'

describe ZencoderJob do
  describe ".only_latest_states" do
    before :each do
      truncate_tables
    end

    it "returns only the latest zencoder jobs in scope of media file" do
      media_file = FactoryGirl.create :media_file
      %w{submitted failed finished}.each do |state|
        ZencoderJob.create(state: state, media_file: media_file)
      end

      expect(ZencoderJob.count).to be== 3
      expect(ZencoderJob.only_latest_states.count).to be== 1
      zencoder_job = ZencoderJob.only_latest_states.first
      expect(zencoder_job.state).to be== "finished"
      expect(zencoder_job.media_file).to be== media_file
    end
  end
end
