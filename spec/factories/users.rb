FactoryGirl.define do
  factory :user do
    sequence :username do |n|
      "jones#{n}"
    end
    
    sequence :email do |n| 
      "jones#{n}@test.com"
    end
    
    password "password"
    password_confirmation "password"
  end
end