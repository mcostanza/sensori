# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :session do
    sequence :title do |n|
      "Title #{n}"
    end

    sequence :description do |n|
      "Description #{n}"
    end

    image { fixture_file_upload(Rails.root.join('spec/data/sensori-mpd.jpg'), 'image/jpeg') }
    
    sequence :end_date do |n|
      Date.today + n.weeks
    end
  
    association :member
  end
end
