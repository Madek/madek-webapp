require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do

  describe 'Action: export' do

    pending 'download original file from export dialog' do
      # go to entry where user has download permissions,
      # click export
      # donwload original file.
      # NOTE: if something doesn't work regarding actual download,
      # move this to madek-integration-tests (MediaEntry up- and download)
      fail 'NOT IMPLEMENTED'
    end

    pending 'download preview from export dialog' do
      # go to entry where user has download permissions,
      # click export
      # donwload original file.
      # NOTE: if something doesn't work regarding actual download,
      # move this to madek-integration-tests (MediaEntry up- and download)
      fail 'NOT IMPLEMENTED'
    end

  end

end
