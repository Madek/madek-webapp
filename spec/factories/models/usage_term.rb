FactoryGirl.define do
  factory :usage_term do
    updated_at {Time.now - 3600}
    title "Nutzungsbedingungen" 
    version {updated_at.to_s}
    intro {Faker::Lorem.words.join(" ")}
    body {Faker::Lorem.words.join(" ")}
  end
end

