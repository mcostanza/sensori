FactoryGirl.define do
  factory :sample_pack do
    sequence(:url) { |n| "http://s3.amazon.com/sensori/sample-packs/#{n}.zip" }
		sequence(:name) { |n| "Sample Pack #{n}" }
		association :session
  end
end
