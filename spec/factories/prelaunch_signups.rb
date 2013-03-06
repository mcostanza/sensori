# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :prelaunch_signup do
    sequence :email do |n|
      "jones#{n}@test.com"
    end
  end
end
