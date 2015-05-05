# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :feature do
    sequence :title do |n|
      "Title #{n}"
    end

    sequence :description do |n|
      "Description #{n}"
    end

    image { fixture_file_upload(Rails.root.join('spec/data/sensori-mpd.jpg'), 'image/jpeg') }

    sequence :link do |n|
      "http://link.com/#{n}"
    end

    association :member
  end
end
