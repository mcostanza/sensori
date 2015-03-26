# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    sequence :soundcloud_id 

    sequence :name do |n|
      "Jones #{n}"
    end

    sequence :slug do |n|
      "jones-#{n}"
    end

    image_url "http://images.com/t500x500.png"
    
    admin false

    sequence :email do |n|
      "jones-#{n}@email.com"
    end

    soundcloud_access_token "tokez"

    trait :admin do
      admin true
    end
  end
end
