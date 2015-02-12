FactoryGirl.define do
  factory :zencoder_job do
    state 'submitted'
    media_file { FactoryGirl.create :media_file_for_movie }
  end
end
