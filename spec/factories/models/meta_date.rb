FactoryGirl.define do

  factory :meta_date do
    timestamp {DateTime.now}
    timezone "+01:00"
    free_text {timestamp.iso8601[0..9]}
  end

end


