# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :discussion_notification do
    association :member
    association :discussion 
  end
end
