# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    association :discussion
    association :member

    sequence :body do |n|
      "Body #{n}"
    end
  end
end
